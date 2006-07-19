require 'rfuzz/stats'
require 'rfuzz/client'

attack :host => "localhost", :port => 3000 do |c,r|
  c.get("/test", :head => r.headers, :query => r.queries)
  c.post("/test", :body => r.words)
  thrash(c, 1000, 10) do |c|
    c.get(r.uris)
  end

  evil :client => c, :stop => r.byte_count, :trickle => r.byte_count
end
