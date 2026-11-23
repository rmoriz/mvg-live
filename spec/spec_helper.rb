require 'rubygems'
require 'minitest/spec'
require 'minitest/autorun'
require 'vcr'
require 'webmock/minitest'

require 'mvg/live'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
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
    live.instance_variable_set(:@response_obj, MVG::Live::HTTP::Response.new(200, body))
  end
end
