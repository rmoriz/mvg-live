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
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "mvg-live"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.1'

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "factory_girl", "~> 2.1.0"
  s.add_development_dependency "vcr"
  s.add_development_dependency "growl"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "pry"

  s.add_runtime_dependency "activemodel", ">= 3.2.1"
  s.add_runtime_dependency "faraday"
  s.add_runtime_dependency "nokogiri"
end
