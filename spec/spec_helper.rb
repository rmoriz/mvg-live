require 'rubygems'
require 'simplecov'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require 'vcr'

SimpleCov.start do
  skip '/spec/'
  skip '/vendor/'
end

SimpleCov.command_name 'test'

require 'mvg/live'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :faraday
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = {
    record: :new_episodes,
    serialize_with: :json
  }
  config.filter_sensitive_data('<MVG_API_KEY>') { MVG::Live::HTTP::API_KEY }
end

# One cassette per test, recorded on demand.
module CassetteHelper
  def before_setup
    super
    VCR.insert_cassette(cassette_name)
  end

  def after_teardown
    VCR.eject_cassette
    super
  end

  def cassette_name
    "#{self.class.name.tr('::', '/')}/#{name}"
  end
end

class Minitest::Spec
  include CassetteHelper

  def build_live(station = nil, transports: MVG::Live::ALL_TRANSPORTS, **options)
    MVG::Live.new(station, { transports: transports }.merge(options))
  end

  def stub_response(live, body)
    response = Struct.new(:body).new(body)
    live.instance_variable_set(:@response_obj, response)
  end
end
