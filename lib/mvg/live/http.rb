require 'faraday'

module MVG
  class Live
    module HTTP
      DEFAULT_BASE_URL = 'https://www.mvg.de/api/bgw-pt/v3'.freeze

      # Public key used by the mvg.de web app. The API also works without it,
      # but sending it keeps us on the same quota/behaviour as the web client.
      API_KEY = '33d2f2c1b7b3b6a7e5f0d4c3b2a1908f'.freeze

      LOCATION_LIMIT     = 10
      MAX_DEPARTURES     = 30
      MAX_STATION_FAILS  = 5

      def connection
        @conn ||= begin
          conn = Faraday.new(url: @base_url) do |builder|
            builder.request :url_encoded
            builder.response :json, content_type: /\bjson$/
            builder.adapter @faraday_adapter
            builder.response :logger, @faraday_logger if @faraday_logger
          end

          conn.headers['Accept'] = 'application/json'
          conn.headers['x-mvg-authority-check-api-key'] = @api_key
          conn
        end
      end

      def retrieve
        return unless valid?

        @response_obj = nil
        @station_unknown = false
        @station_alternates = []

        resolve_station
        return if @station_unknown

        @response_obj = connection.get('departures', build_request_params)
      end

      # Looks up the station and stores the matching station id. Ambiguous or
      # unknown names are recorded as suggestions instead.
      def resolve_station
        query = station_to_mvg(@station)
        wanted = normalize_station(query)

        response = connection.get('locations', query: query, limit: LOCATION_LIMIT)
        @response_obj = response

        body = response.body
        candidates = body.is_a?(Array) ? body.select { |location| location['type'] == 'STATION' } : []
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
        to_utf8(value.to_s)
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
    end
  end
end
