require 'spec_helper'
require 'tempfile'

describe MVG::Live do
  BASE_TIME = Time.utc(2030, 1, 1, 12, 0, 0)
  BASE_MS   = (BASE_TIME.to_f * 1000).to_i

  describe 'when initialized' do
    it 'can be created with no arguments' do
      assert_instance_of MVG::Live, build_live
    end

    it 'can be created for a specific station' do
      assert_match 'Westfriedhof', build_live('Westfriedhof').station
    end

    it 'can be created for specific transports' do
      transports = %i[u bus tram s]
      assert_same transports, build_live('Westfriedhof', transports: transports).transports
    end

    it 'defaults to all transports' do
      assert_equal %i[u bus tram s], build_live.transports
    end
  end

  describe 'validations' do
    it 'should not be valid without a station' do
      live = build_live
      live.station = nil
      assert_equal false, live.valid?
    end

    it 'should be valid with a station and the default transports' do
      assert_equal true, build_live('Westfriedhof').valid?
    end

    it 'should not be valid with invalid transports' do
      live = build_live('Hauptbahnhof', transports: %i[transrapid express_s_bahn_zum_flughafen])
      assert_equal false, live.valid?
      assert_includes live.errors.attribute_names, :transports
    end

    it 'raises when fetching an invalid instance' do
      assert_raises(ArgumentError) { build_live.fetch }
    end
  end

  describe 'dependencies' do
    it 'ships without runtime dependencies' do
      spec = Gem::Specification.load('mvg-live.gemspec')
      assert_empty spec.runtime_dependencies
    end
  end

  describe 'HTTP' do
    it 'should point to the correct host and api version' do
      assert_equal 'https://www.mvg.de/api/bgw-pt/v3', build_live('Westfriedhof').base_url
    end

    it 'should send the api key header' do
      assert_equal MVG::Live::HTTP::API_KEY,
                   build_live('Westfriedhof').build_request_headers['x-mvg-authority-check-api-key']
    end

    it 'should build the right query' do
      live = build_live('Westfriedhof', transports: %i[u tram])
      live.instance_variable_set(:@global_id, 'de:09162:4')
      assert_equal(
        {
          globalId: 'de:09162:4',
          limit: MVG::Live::HTTP::MAX_DEPARTURES,
          transportTypes: 'UBAHN,TRAM'
        },
        live.build_request_params
      )
    end

    it 'logs the request when a logger is given' do
      logger = Class.new do
        attr_reader :lines

        def initialize
          @lines = []
        end

        def debug(line)
          @lines << line
        end
      end.new

      build_live('Westfriedhof', logger: logger).retrieve
      refute_empty logger.lines
      assert_match(/\AGET https:\/\/www\.mvg\.de\/api\/bgw-pt\/v3\/locations/, logger.lines.first)
    end

    it 'falls back to the raw body for non-JSON responses' do
      live = build_live('Westfriedhof')
      response = Struct.new(:body).new('<html>Service unavailable</html>')
      assert_equal '<html>Service unavailable</html>', live.send(:parse_body, response)
    end

    it 'should provide the response object after retrieving' do
      live = build_live('Westfriedhof')
      live.retrieve
      assert_instance_of MVG::Live::HTTP::Response, live.response_obj
      assert_match(/\Ade:\d+:\d+\z/, live.global_id)
    end
  end

  describe 'station lookup' do
    it 'suggests alternatives for unknown stations' do
      live = build_live('Tor', now: BASE_TIME)
      live.fetch
      assert_equal true, live.station_unknown
      assert_includes live.station_alternates, 'Sendlinger Tor'
      assert_nil live.result_sorted
    end

    it 'matches station names case-insensitively' do
      live = build_live('hackerbrücke', now: BASE_TIME)
      live.fetch
      assert_equal false, live.station_unknown
      refute_nil live.global_id
    end

    it 'strips station additions in parentheses' do
      live = build_live('Hauptbahnhof', now: BASE_TIME)
      live.fetch
      assert_equal false, live.station_unknown
      assert_operator live.result_sorted.size, :>, 0
    end
  end

  describe 'fetching departures' do
    before do
      @live = build_live('Hackerbrücke', transports: %i[tram s], now: BASE_TIME)
      @live.fetch
    end

    it 'returns a usable data structure' do
      assert_instance_of Array, @live.result_display
      refute_empty @live.result_display
      @live.result_display.each do |entry|
        assert_instance_of String, entry[:line]
        assert_instance_of String, entry[:destination]
        assert_instance_of Integer, entry[:minutes]
      end
    end

    it 'returns valid UTF-8 destinations' do
      @live.result_display.map { |entry| entry[:destination] }.each do |destination|
        assert destination.valid_encoding?
      end
    end

    it 'sorts the sorted result by departure time' do
      minutes = @live.result_sorted.map { |entry| entry[:minutes] }
      assert_equal minutes.sort, minutes
    end

    it 'exposes the server time' do
      assert_match(/\A\d{2}:\d{2}\z/, @live.server_time)
    end

    it 'restricts the request to the selected transports' do
      lines = @live.result_display.map { |entry| entry[:line] }
      refute_empty lines
      lines.each { |line| refute_match(/\AU\d/, line) }
    end
  end

  describe 'transport filtering' do
    it 'only returns U-Bahn departures when only U-Bahn is requested' do
      live = build_live('Westfriedhof', transports: [:u], now: BASE_TIME)
      live.fetch
      lines = live.result_display.map { |entry| entry[:line] }
      refute_empty lines
      lines.each { |line| assert_match(/\AU\d/, line) }
    end
  end

  describe 'Parser' do
    before do
      @live = build_live('Hackerbrücke', now: BASE_TIME)
      stub_response(@live, [
        { 'label' => '17', 'destination' => 'Schwanseestraße', 'realtimeDepartureTime' => BASE_MS },
        { 'label' => 'S8', 'destination' => 'Herrsching', 'realtimeDepartureTime' => BASE_MS + 240_000 },
        { 'label' => '16', 'destination' => 'St. Emmeram', 'plannedDepartureTime' => BASE_MS + 120_000 },
        { 'label' => 'N17', 'destination' => 'Effnerplatz', 'realtimeDepartureTime' => BASE_MS - 60_000 },
        { 'label' => 'S1', 'destination' => 'Flughafen', 'realtimeDepartureTime' => BASE_MS + 600_000, 'cancelled' => true }
      ])
      @live.parse
    end

    it 'keeps the order of the response for display' do
      assert_equal(
        [
          ['17', 'Schwanseestraße', 0],
          ['S8', 'Herrsching', 4],
          ['16', 'St. Emmeram', 2],
          ['N17', 'Effnerplatz', 0]
        ],
        @live.result_display.map { |entry| [entry[:line], entry[:destination], entry[:minutes]] }
      )
    end

    it 'sorts by minutes, line and destination' do
      assert_equal(
        [['17', 0], ['N17', 0], ['16', 2], ['S8', 4]],
        @live.result_sorted.map { |entry| [entry[:line], entry[:minutes]] }
      )
    end

    it 'skips cancelled departures' do
      refute_includes @live.result_display.map { |entry| entry[:line] }, 'S1'
    end

    it 'drops departures beyond the default 60 minutes' do
      @live.instance_variable_set(:@response_obj, MVG::Live::HTTP::Response.new(200, [
        { 'label' => '16', 'destination' => 'St. Emmeram', 'realtimeDepartureTime' => BASE_MS + 59 * 60_000 },
        { 'label' => '17', 'destination' => 'Schwanseestraße', 'realtimeDepartureTime' => BASE_MS + 61 * 60_000 }
      ]))
      @live.parse
      assert_equal ['16'], @live.result_display.map { |entry| entry[:line] }
    end

    it 'keeps all departures with all: true' do
      live = build_live('Hackerbrücke', now: BASE_TIME, all: true)
      stub_response(live, [
        { 'label' => '16', 'destination' => 'St. Emmeram', 'realtimeDepartureTime' => BASE_MS + 59 * 60_000 },
        { 'label' => '17', 'destination' => 'Schwanseestraße', 'realtimeDepartureTime' => BASE_MS + 120 * 60_000 }
      ])
      live.parse
      assert_equal %w[16 17], live.result_display.map { |entry| entry[:line] }
      assert_nil live.max_minutes
    end

    it 'honours a custom max_minutes' do
      live = build_live('Hackerbrücke', now: BASE_TIME, max_minutes: 10)
      stub_response(live, [
        { 'label' => '16', 'destination' => 'St. Emmeram', 'realtimeDepartureTime' => BASE_MS + 5 * 60_000 },
        { 'label' => '17', 'destination' => 'Schwanseestraße', 'realtimeDepartureTime' => BASE_MS + 11 * 60_000 }
      ])
      live.parse
      assert_equal ['16'], live.result_display.map { |entry| entry[:line] }
    end

    it 'handles error objects instead of a departure array' do
      stub_response(@live, { 'status' => 404, 'error' => 'Not Found' })
      assert_equal [], @live.parse
    end
  end

  describe 'CLI' do
    it 'parses the --all flag and keeps the station intact' do
      parsed = MVG::Live::CLI.parse_argv(['--all', 'Hauptbahnhof'])
      assert_equal true, parsed[:all]
      assert_equal 'Hauptbahnhof', parsed[:station]
    end

    it 'parses --help' do
      assert_equal true, MVG::Live::CLI.parse_argv(['--help'])[:help]
      assert_equal true, MVG::Live::CLI.parse_argv(['-h'])[:help]
    end

    it 'documents the default limit in the usage text' do
      assert_includes MVG::Live::CLI.usage, MVG::Live::DEFAULT_MAX_MINUTES.to_s
    end
    it 'should apply the following convenience hacks' do
      hacks = [
        ['Stachus',         'Karlsplatz (Stachus)'],
        ['Karlsplatz',      'Karlsplatz (Stachus)'],
        ['Moosach Bf',      'Moosach'],
        ['Moosach Bf.',     'Moosach'],
        ['Moosach Bahnhof', 'Moosach']
      ]

      hacks.each do |hack|
        assert_equal hack[1], build_live.cli_station_hacks_for(hack[0])
      end
    end

    it 'resolves the hacked station names in CLI mode' do
      live = build_live('Moosach Bf', transports: [:u], cli: true)
      live.fetch
      assert_equal false, live.station_unknown
      refute_nil live.global_id
    end

    it 'only applies the hacks in CLI mode' do
      live = build_live('Stachus', cli: true)
      assert_equal 'Karlsplatz (Stachus)', live.send(:station_to_mvg, 'Stachus')
      assert_equal 'Stachus', build_live('Stachus').send(:station_to_mvg, 'Stachus')
    end

    it 'loads the default station and transports from MVG_FILE' do
      file = Tempfile.new('mvg')
      file.write(JSON.generate('default_transports' => ['u'], 'default_station' => 'Hauptbahnhof'))
      file.flush

      ENV['MVG_FILE'] = file.path
      live = build_live(nil, transports: [], load_user_defaults: true)
      assert_equal 'Hauptbahnhof', live.station
      assert_equal [:u], live.transports
      assert_equal file.path, live.using_config_file
    ensure
      ENV.delete('MVG_FILE')
      file.close!
    end

    it 'keeps the given station when loading defaults' do
      file = Tempfile.new('mvg')
      file.write(JSON.generate('default_station' => 'Hauptbahnhof'))
      file.flush

      ENV['MVG_FILE'] = file.path
      assert_equal 'Marienplatz', build_live('Marienplatz', load_user_defaults: true).station
    ensure
      ENV.delete('MVG_FILE')
      file.close!
    end
  end

  describe 'Output' do
    before do
      @live = build_live('Hackerbrücke', transports: %i[tram])
      @live.instance_variable_set(:@server_time, '12:34')
      @live.instance_variable_set(:@result_sorted, [
        { line: '16', destination: 'St. Emmeram', minutes: 2 }
      ])
    end

    describe 'display' do
      it 'lists the departures' do
        output = @live.to_display
        assert_includes output, '[ 12:34 ]'
        assert_includes output, '16  | St. Emmeram                   |  2 Minuten'
        assert_includes output, 'Hackerbrücke: Tram'
      end

      it 'lists alternatives for unknown stations' do
        live = build_live('Tor', now: BASE_TIME)
        live.instance_variable_set(:@station_unknown, true)
        live.instance_variable_set(:@station_alternates, ['Sendlinger Tor'])
        assert_includes live.to_display, ' - Sendlinger Tor'
      end
    end

    describe 'JSON' do
      it 'contains the result and meta data' do
        parsed = JSON.parse(@live.to_json, symbolize_names: true)
        assert_equal 'Hackerbrücke', parsed[:station]
        assert_equal '12:34', parsed[:server_time]
        assert_equal 60, parsed[:max_minutes]
        assert_equal [{ line: '16', destination: 'St. Emmeram', minutes: 2 }], parsed[:result_sorted]
      end
    end
  end
end
