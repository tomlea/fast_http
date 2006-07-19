require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'tools/rakehelp'
require 'fileutils'
include FileUtils

setup_tests
setup_clean ["pkg", "lib/*.bundle", "*.gem", ".config"]

setup_rdoc ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc']

setup_extension('http11_client','http11_client')
setup_extension('fuzzrnd','fuzzrnd')

desc "Does a full compile, test run"
task :default => [:http11_client, :fuzzrnd, :test]

version="0.5"
name="rfuzz"

setup_gem(name, version) do |spec|
  spec.summary = "The rfuzz web server destructor"
  spec.description = spec.summary
  spec.author="Zed A. Shaw"
  spec.add_dependency("mongrel",">= 0.3.13.3")
  spec.files += Dir.glob("resources/**/*")
  spec.files += Dir.glob("ext/**/*.rl")
end


task :ragel do
  sh %{/usr/local/bin/ragel ext/http11_client/http11_parser.rl | /usr/local/bin/rlcodegen -G2 -o ext/http11_client/http11_parser.c}
end

task :install => [:test, :package] do
  sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{name}}
end

task :project => [:clean, :ragel, :default, :test, :rdoc, :rcov, :package] do
  print "Username: "
  username = STDIN.readline.strip
  sh %{rsync -avz pkg/*.gem pkg/*.tgz doc/rdoc/* test/coverage #{username}@www.zedshaw.com:zedshaw.com/projects/rfuzz/}
end