
# Copyright (c) 2006 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.

require 'test/unit'
require 'http11_client'
require 'socket'

include RFuzz

class HttpClientParserTest < Test::Unit::TestCase
    
  def test_parse_simple
    parser = HttpClientParser.new
    req = HttpResponse.new
    http = "HTTP/1.1 200 OK\r\nContent-Length: 20\r\n\r\n01234567890123456789"
    nread = parser.execute(req, http, 0)
    assert_equal 39, nread, "Failed to parse the full HTTP request after #{nread}"
    assert parser.finished?, "Parser didn't finish"
    assert !parser.error?, "Parser had error"
    assert nread == parser.nread, "Number read returned from execute does not match"
    assert_equal "20", req["CONTENT_LENGTH"], "Wrong content length header"
    parser.reset
    assert parser.nread == 0, "Number read after reset should be 0"
  end

  def parse(body, size, expect_req)
    parser = HttpClientParser.new
    req = HttpResponse.new
    nread = parser.execute(req, body, 0)
    assert_equal nread, body.length
    assert !parser.error?
    assert parser.finished?

    # check data results
    assert_equal size, req.http_chunk_size.to_i
    expect_req.each {|k,v|assert_not_nil k; assert_equal req[k.upcase], v}
  end

  def test_http_parser
    parse "3;test=stuff;lone\r\n", 3, {"test" => "stuff", "lone" => ""}
    parse "0\r\n",0,{}
    parse "\r\n",0,{}
    parse ";test;test2=test2\r\n",0,{"test" => "", "test2" => "test2"}
    parse "0;test;test2=test2\r\n",0,{"test" => "", "test2" => "test2"}
  end

end
