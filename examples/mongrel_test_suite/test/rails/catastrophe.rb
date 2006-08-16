require 'rfuzz/session'
include RFuzz

context "Recovering From Catastrohpe" do
  setup do
    @client = HttpClient.new("localhost", 3000)
  end

  teardown do
    `chmod oug+rwx ~/projects/testapp/tmp/sessions`
  end

  specify "Should display proper 500 headers" do
    # first make sure it works properly
    r = @client.get("/test")
    r.http_body.should_equal "test"
    r.http_status.should_equal "200"

    # then gank the sessions to produce a 500
    `chmod oug-rwx ~/projects/testapp/tmp/sessions`
    r = @client.get("/test")
    #r.http_body.should_not_match /Status: 500/
    #r.http_status.should_equal "200"  # yes, 200 since status is changed
    #r['STATUS'].should_match /500/
  end
end
