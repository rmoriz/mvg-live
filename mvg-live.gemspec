# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'mvg/live/version'

Gem::Specification.new do |s|
  s.name        = 'mvg-live'
  s.version     = MVG::Live::VERSION
  s.authors     = ['Roland Moriz']
  s.email       = ['roland@moriz.de']
  s.homepage    = 'https://github.com/rmoriz/mvg-live'
  s.license     = 'MIT'
  s.summary     = 'A CLI and ruby client for the MVG real-time departure monitor'
  s.description = "A CLI and ruby client for the real-time departure monitor of Munich's public transport (MVG), based on the JSON API of mvg.de"

  s.files         = Dir.glob('{bin,lib}/**/*', base: __dir__) +
                    %w[CHANGELOG.md LICENSE README.md]
  s.test_files    = Dir.glob('{spec,test,features}/**/*', base: __dir__)
  s.executables   = Dir.glob('bin/*', base: __dir__).map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2.0'

  s.add_runtime_dependency 'activemodel', '~> 8.0'
  s.add_runtime_dependency 'activesupport', '~> 8.0'
  s.add_runtime_dependency 'faraday', '~> 2.0'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'vcr', '~> 6.0'
end
