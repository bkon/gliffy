require 'rubygems'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec' 

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Run test"
task :default => :spec
