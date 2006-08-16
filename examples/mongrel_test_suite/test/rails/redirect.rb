require 'rfuzz/session'
include RFuzz

context "Rails Should Redirect" do
  setup do
    @client = HttpClient.new("localhost","3000")
  end

  specify "with 302" do
    res = @client.get("/test/redirect")
    res.http_status.should_equal "302"
  end
end
