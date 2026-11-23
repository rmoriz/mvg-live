require 'json'
require 'net/http'
require 'uri'

module MVG
  class Live
    module HTTP
      DEFAULT_BASE_URL = 'https://www.mvg.de/api/bgw-pt/v3'
      API_KEY = '33d2f2c1b7b3b6a7e5f0d4c3b2a1908f'

      LOCATION_LIMIT    = 10
      MAX_DEPARTURES    = 30
      MAX_STATION_FAILS = 5

      OPEN_TIMEOUT = 5
      READ_TIMEOUT = 15

      Response = Struct.new(:status, :body)

      def retrieve
        return unless valid?

        @response_obj = nil
        @station_unknown = false
        @station_alternates = []

        resolve_station
        return if @station_unknown

        @response_obj = request('departures', build_request_params)
      end

      # Looks up the station and stores the matching station id. Ambiguous or
      # unknown names are recorded as suggestions instead.
      def resolve_station
        query = station_to_mvg(@station)
        wanted = normalize_station(query)

        response = request('locations', query: query, limit: LOCATION_LIMIT)
        @response_obj = response

        candidates = response.body.is_a?(Array) ? response.body.select { |l| l['type'] == 'STATION' } : []
        match = candidates.find { |location| station_names(location).include?(wanted) }

        if match
          @global_id = match['globalId']
        else
          @station_unknown = true
          @station_alternates = candidates.first(MAX_STATION_FAILS).map { |location| to_utf8(location['name']) }
        end
      end

      def build_request_params
        params = { globalId: @global_id, limit: MAX_DEPARTURES }
        params[:transportTypes] = transports.map { |transport| transport_to_mvg(transport).upcase }.join(',')
        params
      end

      def station_names(location)
        [location['name'], location['aliases']]
          .compact
          .flat_map { |value| normalize_station(value).split(',') }
          .map(&:strip)
      end

      def normalize_station(value)
        to_utf8(value)
          .gsub(/\([^)]*\)/, ' ')
          .squeeze(' ')
          .strip
          .downcase
      end

      def station_to_mvg(station)
        station = to_utf8(station)

        if @cli
          cli_station_hacks_for(station)
        else
          station
        end
      end

      def transport_to_mvg(transport)
        case transport
        when :u
          'ubahn'
        when :s
          'sbahn'
        else
          transport.to_s
        end
      end

      def build_request_headers
        {
          'Accept' => 'application/json',
          'x-mvg-authority-check-api-key' => @api_key
        }
      end

      private

      def request(path, params)
        uri = URI.join("#{@base_url}/", path)
        uri.query = URI.encode_www_form(params)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.open_timeout = OPEN_TIMEOUT
        http.read_timeout = READ_TIMEOUT

        http_request = Net::HTTP::Get.new(uri)
        build_request_headers.each { |name, value| http_request[name] = value }

        response = http.request(http_request)
        @logger&.debug("#{http_request.method} #{uri} -> #{response.code}")

        Response.new(response.code.to_i, parse_body(response))
      end

      def parse_body(response)
        body = response.body.to_s.dup.force_encoding('UTF-8')
        JSON.parse(body)
      rescue JSON::ParserError
        body
      end
    end
  end
end
