# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mvg/live/version'

Gem::Specification.new do |s|
  s.name        = 'mvg-live'
  s.version     = MVG::Live::VERSION
  s.authors     = ['Roland Moriz']
  s.email       = ['roland@moriz.de']
  s.homepage    = ''
  s.summary     = %q{A CLI and ruby client for mvg-live.de}
  s.description = %q{A CLI and ruby client for mvg-live.de, the real-time interface to Munich's public transport}

  s.rubyforge_project = 'mvg-live'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.2'

  if RUBY_PLATFORM == 'java'
    s.add_runtime_dependency 'jruby-openssl'
  end

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'factory_girl', '~> 4.1.0'
  s.add_development_dependency 'vcr', '~> 2.3.0'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'mocha', '~> 1.1.0'
  s.add_development_dependency 'simplecov'

  s.add_runtime_dependency 'activemodel',   '~> 4.1.1'
  s.add_runtime_dependency 'faraday',       '~> 0.8.4'
  s.add_runtime_dependency 'nokogiri',      '~> 1.5.5'
  s.add_runtime_dependency 'json'
end
