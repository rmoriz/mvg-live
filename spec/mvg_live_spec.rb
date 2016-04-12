# encoding: UTF-8
require 'spec_helper'

describe MVG::Live, vcr: { record: :new_episodes } do
  #
  # before do
  #   # https://github.com/myronmarston/vcr/wiki/Usage-with-MiniTest
  #   VCR.insert_cassette __name__
  # end
  #
  # after do
  #   VCR.eject_cassette
  # end

  describe 'when initialized' do
    it 'can be created with no arguments' do
      mvglive = MVG::Live.new
      mvglive.must_be_instance_of MVG::Live
    end

    it 'can be created for a specific station' do
      mvglive = MVG::Live.new 'Westfriedhof'
      mvglive.station.must_match 'Westfriedhof'
    end

    it 'can be created for a specific transports' do
      transports = [:u, :bus, :tram, :s]
      mvglive = MVG::Live.new 'Westfriedhof', transports: transports
      mvglive.transports.must_be_same_as transports
    end
  end

  describe 'validations' do
    it 'should not valid without a station' do
      mvglive = MVG::Live.new
      mvglive.station = nil
      mvglive.valid?.must_equal false
    end

    it 'should be valid with a station and the default transports' do
      mvglive = build(:westfriedhof)
      mvglive.valid?.must_equal true
    end

    it 'should not be valid with invalid transports' do
      transports = [:transrapid, :express_s_bahn_zum_flughafen]
      mvglive = MVG::Live.new 'Vom äh Hauptbahnof äh abfliegen', transports: transports
      mvglive.valid?.must_equal false
      mvglive.errors.keys.must_include :transports
    end
  end

  describe 'HTTP' do
    it 'should return a faraday connection object' do
      mvglive = build(:westfriedhof)
      mvglive.connection.must_be_instance_of Faraday::Connection
    end

    it 'should point to the correct host' do
      mvglive = build(:westfriedhof)
      mvglive.connection.host.must_equal 'www.mvg-live.de'
    end

    it 'should build the right query' do
      mvglive = build(:westfriedhof)
      mvglive.retrieve.env[:url].to_s
                                .must_equal 'http://www.mvg-live.de' \
                    '/ims/dfiStaticAuswahl.svc' \
                    '?bus=checked&haltestelle=Westfriedhof' \
                    '&tram=checked&ubahn=checked'
    end

    it 'should provide cached access to the response object through @response_obj' do
      mvglive = build(:westfriedhof)
      mvglive.retrieve
      mvglive.response_obj.must_be_instance_of Faraday::Response
    end

    it 'should apply some station hacks'
  end

  describe 'Parser' do
    describe 'unknown station' do
      it 'should inform about incorrent stations and possible fits' do
        @mvglive = MVG::Live.new 'Moosfeld'
        @mvglive.fetch
        @mvglive.station_unknown.must_equal true
      end
    end

    describe 'with S-Bahn' do
      before do
        @mvglive = build(:hackerbruecke)
        @mvglive.retrieve
        @mvglive.parse
      end

      describe 'display' do
        it 'should have the correct entry size' do
          @mvglive.result_display.must_be_instance_of Array
          @mvglive.result_display.size.must_equal 20
        end

        it 'should have the correct order ' do
          @mvglive.result_display.map do |e|
            [e[:line], e[:destination], e[:minutes]]
          end.must_equal [
            ['17', "Schwanseestraße", 2],
            ['16', 'St. Emmeram', 2],
            ['17', "Amalienburgstraße", 4],
            ['16', 'St. Emmeram', 7],
            ['16', 'Romanplatz', 10],
            ['17', "Schwanseestraße", 12],
            ['17', "Amalienburgstraße", 15],
            ['S2', 'Erding', 1],
            ['S2', "Altomünster", 2],
            ['S2', 'Petershausen(Obb)', 2],
            ['S8', "München Flughafen Terminal", 4],
            ['S6', 'Tutzing', 4],
            ['S7', 'Wolfratshausen', 6],
            ['S1', "München Ost", 7],
            ['S1', "München Ost", 7],
            ['S4', 'Grafing Bahnhof', 9],
            ['S3', 'Mammendorf', 10],
            ['S3', 'Holzkirchen', 12],
            ['S4', 'Geltendorf', 14],
            ['S1', "München Flughafen Terminal", 16]
          ]
        end
      end

      describe 'sorted' do
        it 'should have the correct entry size' do
          @mvglive.result_sorted.must_be_instance_of Array
          @mvglive.result_sorted.size.must_equal 20
        end

        it 'should have the correct order' do
          @mvglive.result_sorted.map { |e| [e[:line], e[:destination], e[:minutes]] }.must_equal [
            ['S2', 'Erding', 1],
            ['S2', 'Petershausen(Obb)', 2],
            ['16', 'St. Emmeram', 2],
            ['17', "Schwanseestraße", 2],
            ['S2', "Altomünster", 2],
            ['17', "Amalienburgstraße", 4],
            ['S6', 'Tutzing', 4],
            ['S8', "München Flughafen Terminal", 4],
            ['S7', 'Wolfratshausen', 6],
            ['16', 'St. Emmeram', 7],
            ['S1', "München Ost", 7],
            ['S1', "München Ost", 7],
            ['S4', 'Grafing Bahnhof', 9],
            ['16', 'Romanplatz', 10],
            ['S3', 'Mammendorf', 10],
            ['17', "Schwanseestraße", 12],
            ['S3', 'Holzkirchen', 12],
            ['S4', 'Geltendorf', 14],
            ['17', "Amalienburgstraße", 15],
            ['S1', "München Flughafen Terminal", 16]
          ]
        end
      end

      describe 'both' do
        it 'should have the same number of entries' do
          @mvglive.result_sorted.size.must_equal @mvglive.result_display.size
        end
      end
    end
  end

  describe 'CLI' do
    it 'should apply convenience hacks on station names' do
      MVG::Live.any_instance.expects(:cli_station_hacks_for)
               .with('Stachus').returns('Karlsplatz (Stachus)')
      MVG::Live.any_instance.expects(:cli_station_hacks_for)
               .with('Karlsplatz').returns('Karlsplatz (Stachus)')
      MVG::Live.any_instance.expects(:cli_station_hacks_for)
               .with('Moosach Bf').returns('Moosach Bf.')
      MVG::Live.any_instance.expects(:cli_station_hacks_for)
               .with('Moosach Bahnhof').returns('Moosach Bf.')
    end

    it 'should apply the following convenince hacks' do
      hacks = [
        ['Stachus',         'Karlsplatz (Stachus)'],
        ['Karlsplatz',      'Karlsplatz (Stachus)'],
        ['Moosach Bf',      'Moosach Bf.'],
        ['Moosach Bahnhof', 'Moosach Bf.']
      ]

      hacks.each do |hack|
        mvglive = MVG::Live.new
        mvglive.cli_station_hacks_for(hack[0]).must_equal hack[1]
      end
    end
  end

  describe 'Output' do
    describe 'JSON' do
    end
  end
end
