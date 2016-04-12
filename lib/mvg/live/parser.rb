require 'nokogiri'

module MVG
  class Live
    module Parser
      def parse(_args = {})
        return unless @response_obj

        @doc = Nokogiri::HTML(@response_obj.body)

        # <table class="departureTable departureView">
        # ...
        # <tr class="rowOdd">
        #   <td class="lineColumn">N16</td>
        #   <td class="stationColumn">
        #     Effnerplatz
        #     <span class="spacer">&nbsp;</span>
        #   </td>
        #   <td class="inMinColumn">13</td>
        # </tr>

        # <tr class="rowEven">
        #   <td class="lineColumn">N16</td>
        #   <td class="stationColumn">
        #     Amalienburgstraße
        #     <span class="spacer">&nbsp;</span>
        #   </td>
        #   <td class="inMinColumn">28</td>
        # </tr>

        # <tr>
        # <td colspan="4" class="sBahnHeader">S-Bahn M&uuml;nchen (Daten DB Regio AG)</td>

        @server_time = @doc.xpath('//td[@class="serverTimeColumn"]/text()')

        results = []

        @doc.xpath('//table[@class="departureTable departureView"]/tr[@class="rowOdd" or @class="rowEven"]').each do |entry|
          result = {}
          result[:line]        = entry.at('td[@class="lineColumn"]/text()').to_s.strip
          result[:destination] = to_utf8(entry.at('td[@class="stationColumn"]/text()').to_s.strip)
          result[:minutes]     = entry.at('td[@class="inMinColumn"]/text()').to_s.to_i

          results << result
        end

        unless results.empty?
          @result_display = results
          @result_sorted  = results.sort_by { |i| i[:minutes] }
          @result_sorted
        else
          @station_unknown = true
          @station_alternates = []

          @doc.xpath('//table[@class="departureTable header"]//li/a/text()').each do |alt|
            @station_alternates << to_utf8(alt.to_s.strip)
          end
        end
      end
    end
  end
end
