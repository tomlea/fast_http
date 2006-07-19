require 'rfuzz/session'

context "Base HTTP Protocol" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

  specify "Blocks Long URIs" do
    @sess.run(10) do |c,r|
      len = r.num(90) + 1
      uris = r.uris(50,len)

      uris.each do |u| 
        # next sample for illegal uris
        @sess.count_errors(:illegal) do
          resp = c.get(u * 512)
          @sess.count resp.http_status
        end
      end
    end
  end

end
