require 'rubygems'
require 'rfuzz/browser'
include RFuzz
require 'pstore'

if ARGV.length != 4
  puts "usage: ruby cl_watcher.rb city cat areaID \"search\""
  exit 1
end

city, cat, areaID, search = ARGV[0], ARGV[1], ARGV[2], ARGV[3]
href_seen = PStore.new("watcher_seen_links.pstore")
web = Browser.new("#{city}.craigslist.org")

loop do

  puts "Checking..."

  web.start("/cgi-bin/search", :query => {"areaID" => areaID, "subAreaID" => "0","query" => search, "catAbbreviation" => cat, "minAsk" => "min", "maxAsk" => "max"})

  href_seen.transaction do
    web.links(/#{city}.craigslist.org\/#{cat}/).each do |link|
      href = link.attributes["href"]
      if !href_seen[href]
        puts href
        puts " -- " + link.children.join
          `firefox '#{href}'`
          href_seen[href] = link
      end
    end
  end

  puts "----\nSleeping..."
  sleep 60 * (rand(10)+3)

end
