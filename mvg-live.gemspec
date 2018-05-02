
$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'mvg/live/version'

Gem::Specification.new do |s|
  s.name        = 'mvg-live'
  s.version     = MVG::Live::VERSION
  s.authors     = ['Roland Moriz']
  s.email       = ['roland@moriz.de']
  s.homepage    = ''
  s.summary     = 'A CLI and ruby client for mvg-live.de'
  s.description = "A CLI and ruby client for mvg-live.de, the real-time interface to Munich's public transport"

  s.rubyforge_project = 'mvg-live'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.2.0'

  s.add_runtime_dependency 'jruby-openssl' if RUBY_PLATFORM == 'java'

  s.add_development_dependency 'factory_bot', '~> 4.8'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'minitest-vcr', '~> 1.4'
  s.add_development_dependency 'mocha', '~> 1.4.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'

  s.add_runtime_dependency 'activemodel',   '~> 5.2'
  s.add_runtime_dependency 'activesupport', '~> 5.2'
  s.add_runtime_dependency 'faraday',       '~> 0.15'
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'nokogiri', '~> 1.8.2'
end
