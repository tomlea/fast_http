#!/usr/bin/env ruby1.9
# Simple script that hits a host port and URI with a bunch of connections
# and measures the timings.
require 'rubygems'

require File.join( File.dirname(__FILE__), '..', 'lib', 'fast_http' )

include FastHttp

Thread.abort_on_exception = true

host, port, uri, count = 'localhost', 80, '/', 1000

@requests = Queue.new()
count.times{@requests << true}
@results = Queue.new()

Result = Struct.new(:started_at, :ended_at, :code) do
  def duration
    ended_at - started_at
  end
end

@threads = []
5.times do
  cl = HttpClient.new(host, port)
  @threads << Thread.start do
    until @requests.empty?
      job = @requests.shift
      begin
        started_at = Time.now
        code = cl.get(uri).http_status.to_i
        ended_at = Time.now
        @results << Result.new(started_at, ended_at, code)
      rescue => e
        p e
      end
    end
  end
end

@stats = {}
@stats.default = 0
@times = []

@results_array = []

collector = Thread.start do
  while result = @results.shift do
    @results_array << result
  end
end

@threads.each do |t|
  t.join
end

@results << false

collector.join

start = @results_array.sort_by{|t| t.started_at}.first.started_at
ended = @results_array.sort_by{|t| t.ended_at}.last.ended_at
mean_response_time = @results_array.inject(0){|total, result| total + result.duration } / @results_array.size
status_codes = @results_array.inject(Hash.new(0)){|acc, result| acc.merge(result.code => acc[result.code] + 1)}

puts "Average Response Time: #{}"
puts "TPS: #{count/(ended - start)}"
puts "Status Codes: #{status_codes.inspect}"
