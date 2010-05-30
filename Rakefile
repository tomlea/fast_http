require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'fileutils'
include FileUtils

desc "Build the Native extension"
task :build do
  cd 'ext/http11_client' do
    ruby 'extconf.rb'
    system 'make'
  end
end

Rake::TestTask.new do |t|
  t.test_files = Dir.glob("test/test_*.rb")
  t.verbose = true
end

Rake::GemPackageTask.new(eval(File.read("fast_http.gemspec"))) do |pkg|
end

desc "Does a full compile, test run"
task :default => [:build, :test]
