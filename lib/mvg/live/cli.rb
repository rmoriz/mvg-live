require 'json'

module MVG
  class Live
    module CLI
      module ClassMethods
        def fetch(*args)
          MVG::Live.new(*args).fetch
        end

        def fetch_to_display(*args)
          MVG::Live.new(*args).fetch_to_display
        rescue ArgumentError => e
          e.message
        end

        def fetch_to_json(*args)
          MVG::Live.new(*args).fetch_to_json
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end


      def fetch_to_display
        fetch
        to_display
      end

      def fetch_to_json
        fetch
        to_json
      end

      def to_display
        txt = ""

        if @using_config_file
          txt += "=[ " + sprintf("%42s", @using_config_file) + " ]=\n"
        else
          txt += "=" * 48 + "\n"
        end

        if @station_unknown
          txt += '   /!\ Station unknown!  Did you mean...? /!\   ' + "\n"
          txt += "=" * 48 + "\n"

          @station_alternates.each do |a|
            txt += " - #{a}\n"
          end

        else
          txt += "#{@station}: #{@transports.map(&:to_s).map(&:capitalize).join(", ")}\n"
          txt += "=" * 38 + "[ #{@server_time} ]=\n"

          @result_sorted.each do |e|
            txt += sprintf "%-4s| %-30s|%3d Minuten\n", e[:line], e[:destination], e[:minutes]
          end
        end

        txt
      end

      def to_json
        response = {}

        response[:station]            = station
        response[:server_time]        = server_time
        response[:transports]         = transports
        response[:using_config_file]  = using_config_file

        response[:result_sorted]      = result_sorted
        response[:result_display]     = result_display

        response[:station_unknown]    = station_unknown
        response[:station_alternates] = station_alternates

        response.to_json
      end

      def load_user_defaults
        file_locations = [
          ENV['MVG_FILE'],
          "#{ENV['PWD']}/.mvg",
          "#{ENV['HOME']}/.mvg"
        ]

        file_locations.each do |file|
          if file && File.exists?(file)
            data = JSON.parse File.read(file)

            if @station.empty? && data['default_station']
              @station = data['default_station']
            end

            @transports = data['default_transports'].map(&:downcase).map(&:to_sym) if data['default_transports']
            @using_config_file = file
            break
          end
        end
      end

      def cli_station_hacks_for(station)
        case station
        when 'Stachus', 'Karlsplatz'
          'Karlsplatz (Stachus)'
        when 'Moosach Bf', 'Moosach Bahnhof'
          'Moosach Bf.'
        else
          station
        end
      end

    end
  end
end
