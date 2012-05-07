require 'faraday'

module MVG
  class Live
    module HTTP

      def connection
        @conn ||= Faraday.new(:url => "#{@schema}://#{@host}" ) do |builder|
          builder.use @faraday_adapter
          builder.response :logger if @faraday_logger
        end
        @conn
      end

      def retrieve
        return unless valid?
        @response_obj = nil

        res = connection.get do |req|
          req.url @path, build_request_params
          req.headers['Content-Type'] = "text/html; charset=UTF-8"
        end
        @response_obj = res
      end

      def build_request_params
        params = {}
        params[:haltestelle] = station_to_mvg(@station)

        transports.each do |available_transport|
          params[transport_to_mvg(available_transport)] = "checked" if @transports.include? available_transport
        end
        params
      end

      def station_to_mvg(station)
        station = to_encoding(station)

        if @cli
          cli_station_hacks_for(station)
        else
          station
        end
      end

      def transport_to_mvg(transport)
        case transport
        when :u
          "ubahn"
        when :s
          "sbahn"
        else
          transport
        end
      end
    end
  end
end
