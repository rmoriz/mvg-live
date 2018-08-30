require 'rubygems'
require 'simplecov'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest-vcr'
require 'mocha/minitest'
require 'vcr'
require 'factory_bot'

SimpleCov.start
SimpleCov.command_name 'test'

require 'mvg/live'

class MiniTest::Spec
  include FactoryBot::Syntax::Methods
end

FactoryBot.find_definitions

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = { record: :new_episodes, serialize_with: :json, preserve_exact_body_bytes: true }
  # c.debug_logger = STDERR
end

MinitestVcr::Spec.configure!
