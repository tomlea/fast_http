
# Copyright (c) 2006 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.

require 'test/unit'
require 'rfuzz/client'
load 'test/server.rb'
require 'digest/md5'

include RFuzz

class TestNotifier < Notifier
  attr_reader :event_count

  def initialize
    @event_count = 0
  end

  def connect(state)
    @event_count += 1
  end

  def send_request(state)
    @event_count += 1
  end

  def read_header(state)
    @event_count += 1
  end

  def read_body(state)
    @event_count += 1
  end

  def close(state)
    @event_count += 1
  end
end

class RFuzzClientTest < Test::Unit::TestCase

  def setup
    @port = 3001
    @host = "127.0.0.1"
    @client = HttpClient.new(@host, @port, :redirect => 10)
  end

  def tearDown
  end

  def test_cookies
    cl = HttpClient.new(@host, @port)
    cl.get("/cookies")
    assert cl.cookies["_session_id"]
    assert_equal 0, $cookies_count
    cl.get("/cookies")
    assert cl.cookies["_session_id"]
    assert_equal 1, $cookies_count
  end

  def test_get
    resp = @client.get("/test/get")
    assert_method "GET", resp
    resp = @client.get("/test/get/query", :query => {"q" => "test"}, :head => { "X-TestSend" => "Status"})
    assert_header("Status", resp)
    resp = @client.get("/test/get/query/header", 
                       :query => {"q" => "test", "a" => [1,2,3]}, 
                       :head => { "X-TestSend" => "Status"})
    assert_header("Status", resp)
  end

  def test_redirect
    resp = @client.get("/redir")
    assert_equal "200", resp.http_status, "wrong status"
  end

  def test_post
    resp = @client.post("/test/post")
    assert_method "POST", resp
    resp = @client.post("/test/post/header", :head => {"X-TestSend" => "Status"}, :body => "TEST BODY")
    assert_body "TEST BODY", resp
  end

  def test_put
    resp = @client.put("/test/put")
    assert_method("PUT",resp)
    resp = @client.put("/test/put/header", :head => {"X-TestSend" => "Status"})
    assert_header("Status", resp)
    resp = @client.put("/test/put/header/multi", :head => {"X-TestSend" => ["Status", "AGAIN"]})
  end

  def test_delete
    resp = @client.delete("/test/delete")
    assert_method("DELETE", resp)
  end

  def test_head
    resp = @client.head("/test/head")
    assert_method("HEAD", resp)
  end

  def test_status
    resp = @client.get("/error404")
    assert_status "404", resp
    resp = @client.get("/test/200")
    assert_status "200", resp
  end

  def test_overrides
    cl = HttpClient.new(@host, @port, :head => {"X-Override" => "Test"})
    assert cl.options[:head], "missing override header"
  end

  def test_allowed_methods
    cl = HttpClient.new(@host, @port, :allowed_methods => [:nada])
    assert_raises HttpClientError do
      cl.get("/test/wrongmethod")
    end
  end


  def test_notifier
    cl = HttpClient.new(@host, @port, :notifier => TestNotifier.new)
    cl.get("/test/notifier")
    assert_equal 10, cl.notifier.event_count, "not all events fired"
   
    # try to get notified about errors
    assert_raises Errno::ECONNREFUSED,Errno::EBADF do
      cl = HttpClient.new(@host, "300", :notifier => TestNotifier.new)
      cl.get("/test/notifier/fail")
    end

    assert_equal 2, cl.notifier.event_count, "not all events fired"
  end


  def test_chunked_encoding
    50.times do
      th = Thread.new { loop { sleep 1 } }

      Timeout::timeout(3) {
        begin
          resp = @client.get("/chunked")
          assert_equal resp["X_REAL_LENGTH"].to_i, resp.http_body.length
          assert_equal resp["X_MD5_SUM"],Digest::MD5.new(resp.http_body).to_s
        rescue
        end
      }
    end
  end


  def assert_method(method, resp)
    assert_equal method, resp.http_body
  end

  def assert_body(body, resp)
    assert_equal body, resp.http_body
  end

  def assert_header(sent, resp)
    assert_equal sent, resp.http_body
  end

  def assert_status(status, resp)
    assert_equal status, resp.http_status
  end



end
