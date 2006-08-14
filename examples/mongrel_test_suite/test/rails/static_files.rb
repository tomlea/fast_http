require 'rfuzz/session'
include RFuzz

context "Serving static files" do
  setup do
    @client = HttpClient.new("localhost", 3000)
  end

  specify "Services index.html by default" do
    default = @client.get("/")
    default.http_status.should_equal "200"

    index = @client.get("/index.html")
    index.http_status.should_equal "200"

    index.http_body.should_equal default.http_body
  end

  specify "Serves static files" do
    railspng = @client.get("/images/rails.png")
    railspng.http_status.should_equal "200"
    railspng.http_body.length.should_equal 1787 
  end


  specify "Proper MIME types" do
    railspng = @client.get("/images/rails.png")
    railspng['CONTENT_TYPE'].should_equal "image/png"

    index = @client.get("/index.html")
    default = @client.get("/")
    default['CONTENT_TYPE'].should_equal index['CONTENT_TYPE']
    default['CONTENT_TYPE'].should_equal "text/html"

    robots = @client.get("/robots.txt")
    robots['CONTENT_TYPE'].should_equal "text/plain"
  end

  specify "404 Missing files" do
    missing = @client.get("/imnothereturdy")
    missing.http_status.should_equal "404"
  end

  specify "Missing Slash then Redirects" do
    # TODO: implement this feature, seems to trip people up
    redir = @client.get("/images")

    redir = @client.get("/javascripts")

    redir = @client.get("/stylesheets")
  end
end


