require 'rubygems'
require 'hpricot'
require 'rfuzz/session'
include RFuzz

agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.4) Gecko/20060608 Ubuntu/dapper-security Firefox/1.5.0.4"

google = HttpClient.new("www.google.com", 80, :redirect => 10)
r = google.get("/search", :head => {"User-Agent" => agent}, :query => {
               "q" => ARGV[0], "hl" => "en", "btnG" => "Google Search"})

if r.http_status != "200"
  puts "Wrong Status: #{r.http_status}, did you forget to search for something?"
else
  doc = Hpricot(r.http_body)
  (doc/:a).each do |link|
    if link.attributes["class"] == "l"
      puts link.attributes["href"]
      puts " -- " + link.children.join
    end
  end
end
