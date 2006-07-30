require 'rfuzz/session'

context "10: Status Code Definitions" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

  specify "10.1: Informational 1xx" do
  end


  specify "10.1.1: 100 Continue" do
  end


  specify "10.1.2: 101 Switching Protocols" do
  end


  specify "10.2: Successful 2xx" do
  end


  specify "10.2.1: 200 OK" do
  end


  specify "10.2.2: 201 Created" do
  end


  specify "10.2.3: 202 Accepted" do
  end


  specify "10.2.4: 203 Non-Authoritative Information" do
  end


  specify "10.2.5: 204 No Content" do
  end


  specify "10.2.6: 205 Reset Content" do
  end


  specify "10.2.7: 206 Partial Content" do
  end


  specify "10.3: Redirection 3xx" do
  end


  specify "10.3.1: 300 Multiple Choices" do
  end


  specify "10.3.2: 301 Moved Permanently" do
  end


  specify "10.3.3: 302 Found" do
  end


  specify "10.3.4: 303 See Other" do
  end


  specify "10.3.5: 304 Not Modified" do
  end


  specify "10.3.6: 305 Use Proxy" do
  end


  specify "10.3.7: 306 (Unused)" do
  end


  specify "10.3.8: 307 Temporary Redirect" do
  end


  specify "10.4: Client Error 4xx" do
  end


  specify "10.4.1: 400 Bad Request" do
  end


  specify "10.4.2: 401 Unauthorized" do
  end


  specify "10.4.3: 402 Payment Required" do
  end


  specify "10.4.4: 403 Forbidden" do
  end


  specify "10.4.5: 404 Not Found" do
  end


  specify "10.4.6: 405 Method Not Allowed" do
  end


  specify "10.4.7: 406 Not Acceptable" do
  end


  specify "10.4.8: 407 Proxy Authentication Required" do
  end


  specify "10.4.9: 408 Request Timeout" do
  end


  specify "10.4.10: 409 Conflict" do
  end


  specify "10.4.11: 410 Gone" do
  end


  specify "10.4.12: 411 Length Required" do
  end


  specify "10.4.13: 412 Precondition Failed" do
  end


  specify "10.4.14: 413 Request Entity Too Large" do
  end


  specify "10.4.15: 414 Request-URI Too Long" do
  end


  specify "10.4.16: 415 Unsupported Media Type" do
  end


  specify "10.4.17: 416 Requested Range Not Satisfiable" do
  end


  specify "10.4.18: 417 Expectation Failed" do
  end


  specify "10.5: Server Error 5xx" do
  end


  specify "10.5.1: 500 Internal Server Error" do
  end


  specify "10.5.2: 501 Not Implemented" do
  end


  specify "10.5.3: 502 Bad Gateway" do
  end


  specify "10.5.4: 503 Service Unavailable" do
  end


  specify "10.5.5: 504 Gateway Timeout" do
  end


  specify "10.5.6: 505 HTTP Version Not Supported" do
  end


end