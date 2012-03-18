# encoding: UTF-8

require 'active_model'
require 'mvg/live/version'
require 'mvg/live/http'
require 'mvg/live/parser'

module MVG
  class Live
    include ActiveModel::Validations
    include MVG::Live::HTTP
    include MVG::Live::Parser

    ALL_TRANSPORTS = [ :ubahn, :bus, :tram, :sbahn ]

    validates :station, presence: true
    validates :transports, presence: true
    validate  :available_transports

    attr_accessor :station
    attr_accessor :transports

    attr_reader :response_obj
    attr_reader :result_display
    attr_reader :result_sorted


    def initialize(*args)
      @station    = args.shift
      opts        = args.shift || {}

      @transports = opts[:transports] || ALL_TRANSPORTS
      @schema     = opts[:schema]     || 'http'
      @host       = opts[:host]       || 'www.mvg-live.de'
      @path       = opts[:path]       || '/ims/dfiStaticAuswahl.svc'
      @encoding   = opts[:encoding]   || 'ISO-8859-1' # MVG, srsly...

      @faraday_adapter = opts[:faraday_adapter] || Faraday::Adapter::NetHttp

      self
    end

    def fetch
      retrieve
      parse
    end

    def available_transports
      unsupported_transports = @transports.to_a - ALL_TRANSPORTS
      if unsupported_transports.presence
        errors.add :transports, "transport(s) #{unsupported_transports.to_s} is/are not available"
      end
    end

    def self.fetch(*args)
      MVG::Live.new(*args).fetch
    end
  end
end
