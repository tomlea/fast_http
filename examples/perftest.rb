# Simple script that hits a host port and URI with a bunch of connections
# and measures the timings.
require 'rubygems'
require 'rfuzz/client'
require 'rfuzz/stats'
include RFuzz



if ARGV.length != 4
  STDERR.puts "usage:  ruby perftest.rb host port uri count"
  exit 1
end

host, port, uri, count = ARGV[0], ARGV[1], ARGV[2], ARGV[3].to_i

codes = {}
cl = HttpClient.new(host, port, :notifier => StatsTracker.new)
count.times do
  begin
    resp = cl.get(uri)
    code = resp.http_status.to_i
    codes[code] ||= 0
    codes[code] += 1
  rescue Object
  end
end

puts cl.notifier.to_s
puts "Status Codes: #{codes.inspect}"
