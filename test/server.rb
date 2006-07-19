require 'rubygems'
require 'mongrel'
require 'digest/md5'
require 'rfuzz/random'

$cookies_count = 0

class CookieHandler < Mongrel::HttpHandler
  def process(request, response)
    if request.params["HTTP_COOKIE"]
      $cookies_count += 1
    end

    response.start do |head,out|
      head["Set-Cookie"] = "_session_id=ASDFADSFASDFADSFADSFDSAFADSF"
      out.write("test")
    end
  end
end

# Returns one of three things to the client as the response body depending
# on what the client sends:
# * the body if larger than 0
# * the HTTP_X_TESTSEND if that's given
# * the REQUEST_METHOD if nothing else
class TestHandler < Mongrel::HttpHandler
  def process(request, response)
    response.start do |head,out|
      head["Content-Type"] = "text/html"
      if request.body.length > 0
        out.write(request.body.read)
      elsif request.params["HTTP_X_TESTSEND"]
        out.write(request.params["HTTP_X_TESTSEND"])
      else
        out.write(request.params["REQUEST_METHOD"])
      end
    end
  end
end


# Returns a test chunked encoding with @random size chunks and then
# sets the X-Real-Length header to what the resulting body should be,
# and X-MD5-Sum to the hash that should result.
class ChunkedHandler < Mongrel::HttpHandler
  def process(request, response)
    response.start do |head,out|
      head['Transfer-Encoding'] = "chunked"

      chunks = []
      @rand = RFuzz::RandomGenerator.new(open("resources/words.txt").read.split("\n"))
      (@rand.num(20)+10).times { 
        chunks << @rand.base64(@rand.num(60)+10).join('') 
      }

      result_body = chunks.join('')
      head['X-Real-Length'] = result_body.length
      head['X-MD5-Sum'] = Digest::MD5.new(result_body)

      chunks.each_with_index {|c,i| 
        # chunk header
        out.write("#{c.length.to_s(base=16)}#{random_chunk_header}\r\n")
        out.write(c)
        out.write("\r\n")
      }

      case @rand.num(4)
      when 0
        out.write("0\r\n")
      when 1
        out.write("\r\n")
      when 2
        out.write("0\r\n#{@random_chunk_header}")
      when 3
        out.write("\r\n#{@random_chunk_header}")
      end
    end
  end

  def random_chunk_header
    if @rand.num(1) == 0
      hash = @rand.hash_of(1,5,:words)[0]
      hash.collect {|k,v| ";#{k}=#{v}"}
    else
      ""
    end
  end
end

config = Mongrel::Configurator.new :host => "127.0.0.1", :port => "3001" do
  listener do
    uri "/cookies", :handler => CookieHandler.new
    uri "/test", :handler => TestHandler.new
    uri "/chunked", :handler => ChunkedHandler.new
    uri "/error404", :handler => Mongrel::Error404Handler.new("file missing")
    redirect "/redir", "/test"
  end
end


$server = Thread.new { config.run; config.join }
