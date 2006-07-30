require 'rfuzz/session'

context "Base HTTP Protocol" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

  specify "Blocks Long URIs" do
    @sess.run(10) do |c,r|
      uris = r.uris(50,r.num(90) + 1)

      uris.each do |u| 
        resp = nil
        @sess.count_errors(:illegal) { resp = c.get(u * 512) }
        resp.http_status.should_match /^2[0-9][0-9]$/ if resp
      end
    end
  end

end
