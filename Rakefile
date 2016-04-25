require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
  t.warning = false
end

desc 'Console'
task :console do
  require 'pry'
  require 'datacenter'
  ARGV.clear
  Pry.start
end

task default: :spec
