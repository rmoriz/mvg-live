module MVG
  class Live
    module Parser
      def parse(_args = {})
        return if @station_unknown
        return unless @response_obj

        @server_time = Time.now.strftime('%H:%M')
        now = (@now || Time.now).to_f * 1000

        body = @response_obj.body
        results = (body.is_a?(Array) ? body : []).reject { |entry| entry['cancelled'] }.map do |entry|
          departure = entry['realtimeDepartureTime'] || entry['plannedDepartureTime']

          {
            line: to_utf8(entry['label'].to_s.strip),
            destination: to_utf8(entry['destination'].to_s.strip),
            minutes: departure ? [((departure - now) / 60_000.0).round, 0].max : 0
          }
        end
        results = results.select { |entry| entry[:minutes] <= @max_minutes } if @max_minutes

        @result_display = results
        @result_sorted  = results.sort_by { |entry| [entry[:minutes], entry[:line], entry[:destination]] }
        @result_sorted
      end
    end
  end
end
