# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{djatoka}
  s.version = "0.4.1"
  s.authors = ["Jason Ronallo", "Willy Mene"]
  s.email = %q{jronallo@gmail.com wmene@stanford.edu}
  s.homepage = %q{http://github.com/jronallo/djatoka}
  s.summary = %q{Djatoka image server helpers for Ruby and Rails.}
  s.description = %q{The djatoka library provides some simple methods for creation of the OpenURLs needed to communicate with the Djatoka image server.}
  s.rubyforge_project = "djatoka"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "addressable"
  s.add_dependency "hashie"
  s.add_dependency "json"
  s.add_dependency "mime-types"

  s.add_dependency "trollop"
  
  s.add_development_dependency "test-unit"
  s.add_development_dependency "mocha"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "equivalent-xml"
end

