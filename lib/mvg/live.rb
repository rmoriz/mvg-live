# encoding: UTF-8
require 'active_model'
require 'mvg/live/version'
require 'mvg/live/encoding'
require 'mvg/live/http'
require 'mvg/live/parser'
require 'mvg/live/cli'

module MVG
  class Live
    include ActiveModel::Validations
    include MVG::Live::Encoding
    include MVG::Live::HTTP
    include MVG::Live::Parser
    include MVG::Live::CLI

    ALL_TRANSPORTS = [:u, :bus, :tram, :s].freeze

    validates :station, presence: true
    validates :transports, presence: true
    validate  :available_transports

    attr_accessor :station
    attr_accessor :transports

    attr_reader :response_obj
    attr_reader :result_display
    attr_reader :result_sorted
    attr_reader :server_time
    attr_reader :cli
    attr_reader :using_config_file
    attr_reader :station_unknown
    attr_reader :station_alternates

    def initialize(*args)
      @station    = args.shift
      opts        = args.shift || {}

      load_user_defaults if opts[:load_user_defaults]

      @transports = opts[:transports] || ALL_TRANSPORTS
      @schema     = opts[:schema]     || 'http'
      @host       = opts[:host]       || 'www.mvg-live.de'
      @path       = opts[:path]       || '/ims/dfiStaticAuswahl.svc'
      @encoding   = opts[:encoding]   || 'iso-8859-1' # MVG, srsly...
      @cli        = opts[:cli]        || false

      @faraday_adapter = opts[:faraday_adapter] || Faraday::Adapter::NetHttp
      @faraday_logger  = opts[:faraday_logger]
      @server_time = '??:??'
      self
    end

    def fetch
      if valid?
        retrieve
        parse
      else
        raise ArgumentError, errors.full_messages.join("\n")
      end
    end

    def available_transports
      unsupported_transports = @transports.to_a - ALL_TRANSPORTS
      if unsupported_transports.presence
        errors.add :transports, "transport(s) #{unsupported_transports} is/are not available"
      end
    end
  end
end
