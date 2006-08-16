require 'rfuzz/session'
include RFuzz


context "Conditional Responses Should Be" do

  setup do
    @client = HttpClient.new("localhost", 3000)
    @path = "/index.html"
    @r = @client.get(@path)
    (@etag = @r['ETAG']).should_not_be_nil
    (@last_modified = @r['LAST_MODIFIED']).should_not_be_nil
    (@content_length = @r['CONTENT_LENGTH']).should_not_be_nil
  end

   specify "304 Not Modified when If-None-Match is the matching ETag" do
     get_head_status_should_be "304", 'If-None-Match' => @etag
   end
 
   specify "304 Not Modified when If-Modified-Since is the matching Last-Modified date" do
     get_head_status_should_be "304", 'If-Modified-Since' => @last_modified
   end
 
   specify "304 Not Modified when If-None-Match is the matching ETag and If-Modified-Since is the matching Last-Modified date" do
     get_head_status_should_be "304", 'If-None-Match' => @etag, 'If-Modified-Since' => @last_modified
   end
 
   specify "200 OK when If-None-Match is invalid" do
     get_head_status_should_be "200", 'If-None-Match' => 'invalid'
     get_head_status_should_be "200", 'If-None-Match' => 'invalid', 'If-Modified-Since' => @last_modified
   end
 
   specify "200 OK when If-Modified-Since is invalid" do
     get_head_status_should_be "200",                           'If-Modified-Since' => 'invalid'
     get_head_status_should_be "200", 'If-None-Match' => @etag, 'If-Modified-Since' => 'invalid'
   end
 
   specify "304 Not Modified when If-Modified-Since is greater than the Last-Modified header, but less than the system time" do
     sleep 2
     last_modified_plus_1 = (Time.httpdate(@last_modified) + 1).httpdate
     get_head_status_should_be "304",                           'If-Modified-Since' => last_modified_plus_1
     get_head_status_should_be "304", 'If-None-Match' => @etag, 'If-Modified-Since' => last_modified_plus_1
   end
 
   specify "200 OK when If-Modified-Since is less than the Last-Modified header" do
     last_modified_minus_1 = (Time.httpdate(@last_modified) - 1).httpdate
     get_head_status_should_be "200",                           'If-Modified-Since' => last_modified_minus_1
     get_head_status_should_be "200", 'If-None-Match' => @etag, 'If-Modified-Since' => last_modified_minus_1
   end
 
   specify "200 OK when If-Modified-Since is a date in the future" do
     the_future = Time.at(2**31-1).httpdate
     get_head_status_should_be "200",                           'If-Modified-Since' => the_future
     get_head_status_should_be "200", 'If-None-Match' => @etag, 'If-Modified-Since' => the_future
   end

  specify "200 OK when If-None-Match is a wildcard" do
    get_head_status_should_be "200", 'If-None-Match' => '*'
    get_head_status_should_be "200", 'If-None-Match' => '*', 'If-Modified-Since' => @last_modified
  end

  def get_head_status_should_be(http_status, headers = {})
      %w{ get head }.each do |method|
        res = @client.send(method, @path, :head => headers)
        res.http_status.should_equal http_status
        res['ETAG'].should_equal @etag
        case res.http_status
        when '304' then
          res['LAST_MODIFIED'].should_be_nil
          res['CONTENT_LENGTH'].should_be_nil
        when '200' then
          @last_modified.should_equal res['LAST_MODIFIED']
          @content_length.should_equal res['CONTENT_LENGTH']
        else
          fail "Incorrect HTTP status code: #{res.http_status}"
        end
      end
  end
end


