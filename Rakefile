require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "djatoka"
    gem.summary = %Q{Djatoka image server helpers for Ruby and Rails.}
    gem.description = %Q{The djatoka library provides some simple methods for creation of the OpenURLs needed to communicate with the Djatoka image server.}
    gem.email = "jronallo@gmail.com"
    gem.homepage = "http://github.com/jronallo/djatoka"
    gem.authors = ["Jason Ronallo"]
    gem.add_development_dependency "shoulda", ">= 0"
    #gem.add_development_dependency "ruby-debug", ">= 0"
    gem.add_development_dependency "hanna", ">= 0"
    gem.add_dependency "addressable", "2.1.2"
    gem.add_development_dependency "curb", ">= 0"
    gem.add_dependency "json", ">= 0"
    gem.add_dependency 'trollop', '>= 0'
    gem.add_dependency 'hashie', '>= 0'
    gem.files = FileList["[A-Z]*", "{bin,generators,lib}/**/*"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "djatoka #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

