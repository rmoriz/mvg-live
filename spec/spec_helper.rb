require 'rubygems'
require 'minitest/spec'
require 'minitest/autorun'
#require 'minitest/reporters'
require 'mvg/live'
require 'vcr'
require 'factory_girl'

#MiniTest::Unit.runner = MiniTest::SuiteRunner.new
#MiniTest::Unit.runner.reporters << MiniTest::Reporters::ProgressReporter.new

class MiniTest::Spec
  include Factory::Syntax::Methods
  alias :method_name :__name__ if defined? :__name__
end

FactoryGirl.find_definitions

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = { :record => :new_episodes, :serialize_with => :json, preserve_exact_body_bytes: true }
end

