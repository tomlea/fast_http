# An example of handing tons of nasty URLs to Rails to see what it does.

require 'rfuzz/session'

include RFuzz

s = Session.new :host => "localhost", :port => 3000
s.run 10, :save_as => ["runs.csv","counts.csv"] do |c,r|
  len = r.num(90) + 1
  s.count :len, len
  uris = r.uris(ARGV[0].to_i,len)

  uris.each do |u| 
    s.count_errors(:legal) do
      # first sample for legal uris
      resp = c.get(u)
      s.count resp.http_status
    end

    # next sample for illegal uris
    s.count_errors(:illegal) do
      resp = c.get(u * 512)
      s.count resp.http_status
    end
  end
end
