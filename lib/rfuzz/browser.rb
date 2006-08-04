require 'rfuzz/session'
require 'hpricot'

module RFuzz

  # A simple class that emulates a browser using hpricot.
  class Browser
    attr_accessor :client
    attr_accessor :doc
    attr_accessor :response
    attr_accessor :agent

    DEFAULT_AGENT="Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.4) Gecko/20060608 Ubuntu/dapper-security Firefox/1.5.0.4"

    # The default agent used is Mozilla (from linux Dapper Drake), but you
    # can change it to something else.
    def initialize(host, port=80, ops={}, agent=DEFAULT_AGENT)
      @agent = agent
      @client = HttpClient.new(host, port, ops)

      ops[:head] ||= {}
      ops[:head]["User-Agent"] ||= @agent 

      @doc = nil
      @response = nil
    end

    # Makes the browser do a GET to this location.  It takes the same
    # params as HttpClient does for any method.
    def start(uri, ops={})
      @response = @client.get(uri,ops)
      if @response.http_status != "200"
        raise "Invalid status: #{@response.http_status}"
      end

      @doc = Hpricot(@response.http_body)
    end

    # Returns an Array of Hpricot objects that are the links on the
    # current page.  If you pass in matching as a regex (or any === 
    # compatible with String) then it'll only return those links.
    def links(matching=nil)
      links = @doc/:a
      if matching
        # return only the ones that match
        return links.select {|l| matching === l.attributes["href"]}
      else
        return links
      end
    end
  end

end
