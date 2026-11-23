require 'json'
require 'mvg/live/version'
require 'mvg/live/http'
require 'mvg/live/parser'
require 'mvg/live/cli'

module MVG
  class Live
    include MVG::Live::HTTP
    include MVG::Live::Parser
    include MVG::Live::CLI

    ALL_TRANSPORTS = %i[u bus tram s].freeze

    # Collects validation errors without pulling in ActiveModel.
    class Errors
      def initialize
        clear
      end

      def clear
        @messages = Hash.new { |hash, key| hash[key] = [] }
      end

      def add(attribute, message)
        @messages[attribute] << message
      end

      def attribute_names
        @messages.keys
      end

      def full_messages
        @messages.flat_map do |attribute, messages|
          messages.map { |message| "#{attribute.to_s.capitalize} #{message}" }
        end
      end

      def empty?
        @messages.values.none? { |messages| messages.any? }
      end
    end

    attr_accessor :station
    attr_accessor :transports

    attr_reader :base_url
    attr_reader :cli
    attr_reader :errors
    attr_reader :global_id
    attr_reader :response_obj
    attr_reader :result_display
    attr_reader :result_sorted
    attr_reader :server_time
    attr_reader :station_alternates
    attr_reader :station_unknown
    attr_reader :using_config_file

    def initialize(*args)
      @station = args.shift
      opts     = args.shift || {}

      load_user_defaults if opts[:load_user_defaults]

      @transports = if opts[:transports] && !opts[:transports].to_a.empty?
                      opts[:transports]
                    else
                      @transports || ALL_TRANSPORTS
                    end
      @base_url   = opts[:base_url] || DEFAULT_BASE_URL
      @api_key    = opts[:api_key]  || API_KEY
      @now        = opts[:now]
      @logger     = opts[:logger]
      @cli        = opts[:cli] || false

      @errors = Errors.new
      @server_time = '??:??'
      @station_unknown = false
      @station_alternates = []
      self
    end

    def fetch
      raise ArgumentError, errors.full_messages.join("\n") unless valid?

      retrieve
      parse
    end

    def valid?
      @errors.clear
      @errors.add(:station, "can't be blank") if @station.to_s.strip.empty?
      @errors.add(:transports, "can't be blank") if @transports.to_a.empty?
      available_transports
      @errors.empty?
    end

    def available_transports
      unsupported_transports = @transports.to_a - ALL_TRANSPORTS
      return unless unsupported_transports.any?

      @errors.add :transports, "transport(s) #{unsupported_transports} is/are not available"
    end

    def to_utf8(value)
      value.to_s.encode('UTF-8')
    end
  end
end
