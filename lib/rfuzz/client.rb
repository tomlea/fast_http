require 'http11_client'
require 'socket'
require 'stringio'
require 'rfuzz/stats'
require 'timeout'

module RFuzz


  # A simple hash is returned for each request made by HttpClient with
  # the headers that were given by the server for that request.  Attached
  # to this are four attributes you can play with:
  #
  #  * http_reason
  #  * http_version
  #  * http_status
  #  * http_body
  #
  # These are set internally by the Ragel/C parser so they're very fast
  # and pretty much C voodoo.  You can modify them without fear once you get 
  # the response.
  class HttpResponse < Hash
    # The reason returned in the http response ("OK","File not found",etc.)
    attr_accessor :http_reason

    # The HTTP version returned.
    attr_accessor :http_version

    # The status code (as a string!)
    attr_accessor :http_status

    # The http body of the response, in the raw
    attr_accessor :http_body

    # When parsing chunked encodings this is set
    attr_accessor :http_chunk_size
  end

  # A mixin that has most of the HTTP encoding methods you need to work
  # with the protocol.  It's used by HttpClient, but you can use it
  # as well.
  module HttpEncoding
    COOKIE="Cookie"

    # Converts a Hash of cookies to the appropriate simple cookie
    # headers.
    def encode_cookies(cookies)
      result = ""
      cookies.each do |k,v|
        if v.kind_of? Array
          v.each {|x| result += encode_field(COOKIE, encode_param(k,x)) }
        else
          result += encode_field(COOKIE, encode_param(k,v))
        end
      end
      return result
    end

    # Encode HTTP header fields of "k: v\r\n"
    def encode_field(k,v)
      "#{k}: #{v}\r\n"
    end

    # Encodes the headers given in the hash returning a string
    # you can use.
    def encode_headers(head)
      result = "" 
      head.each do |k,v|
        if v.kind_of? Array
          v.each {|x| result += encode_field(k,x) }
        else
          result += encode_field(k,v)
        end
      end
      return result
    end

    # URL encodes a single k=v parameter.
    def encode_param(k,v)
      escape(k) + "=" + escape(v)
    end

    # Takes a query string and encodes it as a URL encoded 
    # set of key=value pairs with & separating them.
    def encode_query(uri, query)
      params = []

      if query
        query.each do |k,v|
          if v.kind_of? Array
            v.each {|x| params << encode_param(k,x) } 
          else
            params << encode_param(k,v)
          end
        end

        uri += "?" + params.join('&')
      end

      return uri
    end

    # HTTP is kind of retarded that you have to specify
    # a Host header, but if you include port 80 then further
    # redirects will tack on the :80 which is annoying.
    def encode_host(host, port)
      "#{host}" + (port.to_i != 80 ? ":#{port}" : "")
    end

    # Performs URI escaping so that you can construct proper
    # query strings faster.  Use this rather than the cgi.rb
    # version since it's faster.  (Stolen from Camping).
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        '%'+$1.unpack('H2'*$1.size).join('%').upcase
      }.tr(' ', '+') 
    end


    # Unescapes a URI escaped string. (Stolen from Camping).
    def unescape(s)
      s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){
        [$1.delete('%')].pack('H*')
      } 
    end

    # Parses a query string by breaking it up at the '&' 
    # and ';' characters.  You can also use this to parse
    # cookies by changing the characters used in the second
    # parameter (which defaults to '&;'.
    def query_parse(qs, d = '&;')
      params = {}
      (qs||'').split(/[#{d}] */n).inject(params) { |h,p|
        k, v=unescape(p).split('=',2)
        if cur = params[k]
          if cur.class == Array
            params[k] << v
          else
            params[k] = [cur, v]
          end
        else
          params[k] = v
        end
      }

      return params
    end
  end


  # The actual HttpClient that does the work with the thinnest
  # layer between you and the protocol.  All exceptions and leaks
  # are allowed to pass through since those are important when
  # testing.  It doesn't pretend to be a full client, but instead
  # is just enough client to track cookies, form proper HTTP requests,
  # and return HttpResponse hashes with the results.
  #
  # It's designed so that you create one client, and then you work it
  # with a minimum of parameters as you need.  The initialize method
  # lets you pass in defaults for most of the parameters you'll need,
  # and you can simple call the method you want and it'll be translated
  # to an HTTP method (client.get => GET, client.foobar = FOOBAR).
  #
  # Here's a few examples:
  #
  #   client = HttpClient.new(:head => {"X-DefaultHeader" => "ONE"})
  #   resp = client.post("/test")
  #   resp = client.post("/test", :head => {"X-TestSend" => "Status"}, :body => "TEST BODY")
  #   resp = client.put("/testput", :query => {"q" => "test"}, :body => "SOME JUNK")
  #   client.reset
  #
  # The HttpClient.reset call clears cookies that are maintained.
  #
  # It uses method_missing to do the translation of .put to "PUT /testput HTTP/1.1"
  # so you can get into trouble if you're calling unknown methods on it.  By
  # default the methods are PUT, GET, POST, DELETE, HEAD.  You can change
  # the allowed methods by passing :allowed_methods => [:put, :get, ..] to
  # the initialize for the object.
  #
  # == Notifications
  #
  # You can register a "notifier" with the client that will get called when
  # different events happen.  Right now the Notifier class just has a few
  # functions for the common parts of an HTTP request that each take a 
  # symbol and some extra parameters.  See RFuzz::Notifier for more 
  # information.
  #
  # == Parameters
  #
  #   :head => {K => V}  or {K => [V1,V2]}
  #   :query => {K => V} or {K => [V1,V2]}
  #   :body => "some body" (you must encode for now)
  #   :cookies => {K => V} or {K => [V1, V2]}
  #   :allowed_methods => [:put, :get, :post, :delete, :head]
  #   :notifier => Notifier.new
  #   :redirect => false (give it a number and it'll follow redirects for that count)
  #
  class HttpClient
    include HttpEncoding

    TRANSFER_ENCODING="TRANSFER_ENCODING"
    CONTENT_LENGTH="CONTENT_LENGTH"
    SET_COOKIE="SET_COOKIE"
    LOCATION="LOCATION"
    HOST="HOST"
    HTTP_REQUEST_HEADER="%s %s HTTP/1.1\r\n"
    REQ_CONTENT_LENGTH="Content-Length"
    REQ_HOST="Host"

    # Access to the host, port, default options, and cookies currently in play
    attr_accessor :host, :port, :options, :cookies, :allowed_methods, :notifier

    # Doesn't make the connect until you actually call a .put,.get, etc.
    def initialize(host, port, options = {})
      @options = options
      @host = host
      @port = port
      @cookies = options[:cookies] || {}
      @allowed_methods = options[:allowed_methods] || [:put, :get, :post, :delete, :head]
      @notifier = options[:notifier]
      @redirect = options[:redirect] || false
    end


    # Builds a full request from the method, uri, req, and @cookies
    # using the default @options and writes it to out (should be an IO).
    # 
    # It returns the body that the caller should use (based on defaults 
    # resolution).
    def build_request(out, method, uri, req)
      ops = @options.merge(req)
      query = ops[:query]

      # merge head differently since that's typically what they mean
      head = req[:head] || {}
      head = ops[:head].merge(head) if ops[:head]

      # setup basic headers we always need
      head[REQ_HOST] = encode_host(@host,@port)
      head[REQ_CONTENT_LENGTH] = ops[:body] ? ops[:body].length : 0

      # blast it out
      out.write(HTTP_REQUEST_HEADER % [method, encode_query(uri,query)])
      out.write(encode_headers(head))
      out.write(encode_cookies(@cookies.merge(req[:cookies] || {})))
      out.write("\r\n")
      ops[:body] || ""
    end

    def read_chunks(input, out, parser)
      begin
        until input.closed?
          parser.reset
          chunk = HttpResponse.new
          line = input.readline("\r\n")
          nread = parser.execute(chunk, line, 0)

          if !parser.finished?
            # tried to read this header but couldn't
            return :incomplete_header, line
          end

          size = chunk.http_chunk_size ? chunk.http_chunk_size.to_i(base=16) : 0

          if size == 0
            return :finished, nil
          end

          remain =  size - out.write(input.read(size))
          return :incomplete_body, remain if remain > 0

          line = input.read(2)
          if line.nil? or line.length < 2
            return :incomplete_trailer, line
          elsif line != "\r\n"
            raise HttpClientParserError.new("invalid chunked encoding trailer")
          end
        end
      rescue EOFError
        # this is thrown when the header read is attempted and 
        # there's nothing in the buffer
        return :eof_error, nil
      end
    end

    def read_chunked_encoding(resp, sock, parser)
      out = StringIO.new
      input = StringIO.new(resp.http_body)

      # read from the http body first, then continue at the socket
      status, result = read_chunks(input, out, parser)

      case status
      when :incomplete_trailer
        if result.nil?
          sock.read(2)
        else
          sock.read(result.length - 2)
        end
      when :incomplete_body
        out.write(sock.read(result))  # read the remaining
        sock.read(2)
      when :incomplete_header
        # push what we read back onto the socket, but backwards
        result.reverse!
        result.each_byte {|b| sock.ungetc(b) }
      when :finished
        # all done, get out
        out.rewind; return out.read
      when :eof_error
        # read everything we could, ignore
      end

      # then continue reading them from the socket
      status, result = read_chunks(sock, out, parser)

      # and now the http_body is the chunk
      out.rewind; return out.read
    end

    # Reads an HTTP response from the given socket.  It uses 
    # readpartial which only appeared in Ruby 1.8.4.  The result
    # is a fully formed HttpResponse object for you to play with.
    # 
    # As with other methods in this class it doesn't stop any exceptions
    # from reaching your code.  It's for experts who want these exceptions
    # so either write a wrapper, use net/http, or deal with it on your end.
    def read_response(sock)
      data, resp = nil, nil
      parser = HttpClientParser.new
      resp = HttpResponse.new

      notify :read_header do
        data = sock.readpartial(1024)
        nread = parser.execute(resp, data, 0)

        while not parser.finished?
          data += sock.readpartial(1024)
          nread += parser.execute(resp, data, nread)
        end
      end

      notify :read_body do
        if resp[TRANSFER_ENCODING] and resp[TRANSFER_ENCODING].index("chunked")
          resp.http_body = read_chunked_encoding(resp, sock, parser)
        elsif resp[CONTENT_LENGTH]
          cl = resp[CONTENT_LENGTH].to_i
          if cl - resp.http_body.length > 0
            resp.http_body += sock.read(cl - resp.http_body.length)
          elsif cl < resp.http_body.length
            STDERR.puts "Web site sucks, they said Content-Length: #{cl}, but sent a longer body length: #{resp.http_body.length}"
          end
        else
          resp.http_body += sock.read
        end
      end

      if resp[SET_COOKIE]
        cookies = query_parse(resp[SET_COOKIE], ';,')
        @cookies.merge! cookies
        @cookies.delete "path"
      end

      notify :close do
        sock.close
      end

      resp
    end

    # Does the socket connect and then build_request, read_response
    # calls finally returning the result.
    def send_request(method, uri, req)
      begin
        sock = nil
        notify :connect do
          sock = TCPSocket.new(@host, @port)
        end

        out = StringIO.new
        body = build_request(out, method, uri, req)

        notify :send_request do
          sock.write(out.string + body)
          sock.flush
        end

        return read_response(sock)
      rescue Object
        raise $!
      ensure
        sock.close unless (!sock or sock.closed?)
      end
    end


    # Translates unknown function calls into PUT, GET, POST, DELETE, HEAD 
    # methods.  The allowed HTTP methods allowed are restricted by the
    # @allowed_methods attribute which you can set after construction or
    # during construction with :allowed_methods => [:put, :get, ...]
    def method_missing(symbol, *args)
      if @allowed_methods.include? symbol
        method = symbol.to_s.upcase
        resp = send_request(method, args[0], args[1] || {})
        resp = redirect(symbol, resp) if @redirect

        return resp
      else
        raise "Invalid method: #{symbol}"
      end
    end

    # Keeps doing requests until it doesn't receive a 3XX request.
    def redirect(method, resp, *args)
      @redirect.times do
        break if resp.http_status.index("3") != 0

        host = encode_host(@host,@port)
        location = resp[LOCATION]

        if location.index(host) == 0
          # begins with the host so strip that off
          location = location[host.length .. -1]
        end

        @notifier.redirect(:begins) if @notifier
        resp = self.send(method, location, *args)
        @notifier.redirect(:ends) if @notifier
      end

      return resp
    end

    # Clears out the cookies in use so far in order to get
    # a clean slate.
    def reset
      @cookies.clear
    end


    # Sends the notifications to the registered notifier, taking
    # a block that it runs doing the :begins, :ends states
    # around it.
    #
    # It also catches errors transparently in order to call
    # the notifier when an attempt fails.
    def notify(event)
      @notifier.send(event, :begins) if @notifier

      begin
        yield
        @notifier.send(event, :ends) if @notifier
      rescue Object
        @notifier.send(event, :error) if @notifier
        raise $!
      end
    end
  end



  # This simple class can be registered with an HttpClient and it'll
  # get called when different parts of the HTTP request happen.
  # Each function represents a different event, and the state parameter
  # is a symbol of consisting of:
  #
  #  :begins -- event begins.
  #  :error -- event caused exception.
  #  :ends -- event finished (not called if error).
  #
  # These calls are made synchronously so you can throttle
  # the client by sleeping inside them and can track timing
  # data.
  class Notifier
    # Fired right before connecting and right after the connection.
    def connect(state)
    end

    # Before and after the full request is actually sent.  This may
    # become "send_header" and "send_body", but right now the whole
    # blob is shot out in one chunk for efficiency.
    def send_request(state)
    end

    # Called whenever a HttpClient.redirect is done and there 
    # are redirects to follow.  You can use a notifier to detect
    # that you're doing to many and throw an abort.
    def redirect(state)
    end

    # Before and after the header is finally read.
    def read_header(state)
    end

    # Before and after the body is ready.
    def read_body(state)
    end

    # Before and after the client closes with the server.
    def close(state)
    end
  end
end
