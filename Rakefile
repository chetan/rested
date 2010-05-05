
begin
  require 'rubygems'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rested"
    gemspec.summary = "Ruby library for working with RESTful APIs"
    gemspec.description = "Ruby library built on top of httpclient for working with RESTful APIs."
    gemspec.email = "chetan@betteradvertising.com"
    gemspec.homepage = ""
    gemspec.authors = ["Chetan Sarva"]
    gemspec.add_dependency('httpclient', '>= 2.1.5.2')
    gemspec.add_dependency('json', '>= 1.4.2')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

require "rake/testtask"
desc "Run unit tests"
Rake::TestTask.new("test") { |t|
    #t.libs << "test"
    t.ruby_opts << "-rubygems"
    t.pattern = "test/**/*_test.rb"
    t.verbose = false
    t.warning = false
}
