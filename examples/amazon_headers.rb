require 'rubygems'
require 'rfuzz/session'
require 'hpricot'

include RFuzz
agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.4) Gecko/20060608 Ubuntu/dapper-security Firefox/1.5.0.4"

amazon = HttpClient.new("www.amazon.com", 80, :head => {"User-Agent" => agent}, :redirect => 10)

r = amazon.get("/")

puts "## AMAZON'S WACKY HEADERS:"
puts r.inspect

puts "\n\n## AMAZON'S LAME EASTER EGG:"
puts r.http_body.split("\n").last

a9 = {}
doc = Hpricot(r.http_body)
(doc/:form).collect {|f|
  if /a9.amazon.com/ === f.attributes["action"]
    a9["action"] = f.attributes["action"]
    a9["method"] = f.attributes["method"]
    (f/:input).each {|i| a9[i.attributes["name"]] = i.attributes }
  end
}

puts "A9 FORM: #{a9.inspect}"
http://pastie.caboo.se/4810
# do a search
_, host, uri = a9["action"].split(/http:\/\/([a-z0-9\.]*)/)

a9client = HttpClient.new(host, 80, :head => {"User-Agent" => agent}, :redirect => 10)
r = a9client.get(uri, :query => {"q" => "test"})

puts "\n\n## RESULTS"
puts r.http_body

