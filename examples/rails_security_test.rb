require 'rubygems'
require 'rfuzz/session'
require 'find'
include RFuzz

if ARGV.length != 3
  puts "usage: ruby rails_security_test.rb <host> <port> <railsdir>"
  exit 1
end

host, port, railsdir = ARGV

if railsdir[-1].chr != "/"
  railsdir += "/"
end

test = HttpClient.new(host, port)
paths = []

Find.find(railsdir) do |path|
  if FileTest.directory?(path)
    if File.basename(path)[0] == ?.
      Find.prune       # Don't look any further into this directory.
    else
      next
    end
  else
    path = path[railsdir.length - 1 .. -1]
    paths << path
    paths << "/" + File.basename(path)
    if path.index(".rb") == path.length - 3
      stripped = path[0 .. -4]
      paths << stripped
      paths << "/" + File.basename(stripped)
    end
  end
end

methods = [:get, :post, :put, :delete, :head]

methods.each do |method|
  paths.each do |path|
    begin
      res = test.send(method,path)

      app_error = case res.http_body
                  when /500/
                  "500"
                  when /[aA]pplication error/
                  "app_error"
                  else
                  "unknown"
                  end

      puts "#{method} #{path} #{res.http_status} #{app_error}"
    rescue
      puts "#{method} #{path}: ERROR! #{$!}"
    end
  end
end

