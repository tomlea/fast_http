require 'rfuzz/session'
include RFuzz

context "PUT Requests" do
  setup do
    @gets = Session.new :host => "localhost", :port => 3000
    @puts = Session.new :host => "localhost", :port => 3000
  end

  specify "Should be fast" do
    data = @gets.rand.bytes(600)
    body = @gets.client.escape(data)

    @gets.run(10, :save_as => ["get_runs.csv", "get_counts.csv"]) do |c,r|
      10.times do
        get = c.get("/test?data=#{body}")
      end
    end

    @puts.run(10, :save_as => ["put_runs.csv", "put_counts.csv"]) do |c,r|
      10.times do
        put = c.put("/test", :body => data)
      end
    end
  end

  specify "Query String should allow 0 length" do
    res = @gets.client.get("/test?")
    res.http_status.should_equal "200"
    res.http_body.should_equal "test"
  end
end
