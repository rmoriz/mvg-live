require 'faraday'

module MVG
  class Live
    module HTTP

      def connection
        @conn ||= Faraday.new(:url => "#{@schema}://#{@host}" ) do |builder|
          builder.use @faraday_adapter
          builder.response :logger

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
        params[:haltestelle] = @station.encode @encoding

        transports.each do |available_transport|
          params[available_transport] = "checked" if @transports.include? available_transport
        end
        params
      end
    end
  end
end
