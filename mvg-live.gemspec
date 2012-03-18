# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mvg/live/version"
require "mvg/live" # remove me?

Gem::Specification.new do |s|
  s.name        = "mvg-live"
  s.version     = MVG::Live::VERSION
  s.authors     = ["Roland Moriz"]
  s.email       = ["roland@moriz.de"]
  s.homepage    = ""
  s.summary     = %q{A CLI and ruby client for mvg-live.de}
  s.description = %q{A CLI and ruby client for mvg-live.de, the real-time interface to Munich's public transport}

  s.rubyforge_project = "mvg-live"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  #s.required_ruby_version = '>= 1.9.3'
  s.required_ruby_version = '>= 1.8.7'

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "factory_girl", "~> 2.1.0"
  s.add_development_dependency "vcr", "~> 2.0.0"
  s.add_development_dependency "growl"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "pry"

  s.add_runtime_dependency "activemodel",   "~> 3.2.2"
  s.add_runtime_dependency "faraday",       "~> 0.7.6"
  s.add_runtime_dependency "nokogiri",      "~> 1.5.2"
  s.add_runtime_dependency "json"

end
