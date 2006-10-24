require 'csv'
require 'rfuzz/random'
require 'rfuzz/client'
require 'rfuzz/stats'

module RFuzz
  # Creates a small light DSL for running RFuzz sessions against a 
  # web server.  It configures a basic client and randomizer that you
  # then use to conduct sessions and record statistics about the activity.
  class Session

    attr_accessor :counts
    attr_accessor :runs
    attr_accessor :tracking
    attr_reader :client
    attr_reader :rand

    # Sets up a session that you then operate by calling Session#run.  Most of the
    # functions do not work unless they are inside a Session#run call.
    #
    # Available options are:
    #
    # * :host => Required.  Which host.
    # * :port => Required.  Which port.
    # * :words => Dictionary to load for the words passed to RandomGenerator.
    # 
    # You can then pass any options you need to pass to the created RFuzz::HttpClient.
    def initialize(options={})
      @host = options[:host]
      @port = options[:port]
      options.delete(:host)
      options.delete(:port)
      options[:notifier] = StatsTracker.new

      @word_file = options[:words] || File.join(File.dirname(__FILE__), "..", "..", "resources","words.txt")

      @client = HttpClient.new(@host, @port, options)
      @rand = RandomGenerator.new(open(@word_file).read.split("\n"))

      @runs = []
      @counts = []
      @tracking = []
    end

    def cur_run
      @runs.last
    end

    def cur_count
      @counts.last
    end

    # Begin a run of count length wher a block is run once and statistics are collected
    # from the client passed to the block.  When calls you can pass in the following options:
    #
    # * :sample => Defaults to [:request], but will record any of [:request, :connect, :send_request, :read_header, :read_body, :close]
    # * :save_as => A tuple of ["runs.csv", "counts.csv"] (or whatever you want to call them).
    #
    # Once you call run, the block you pass it is given an HttpClient and a RandomGenerator.  Each run will reset the HttpClient so you can pretend it is brand new.
    #
    def run(count=1, options={})
      sample = options[:sample] || [:request]
      count.times do |i|
        # setup for this latest sample run
        @runs << {}
        @counts << {}
        @tracking << {}
        yield @client, @rand

        # record the request stats then reset them
        sample.each {|s| cur_run[s] = @client.notifier.stats[s].clone if @client.notifier.stats[s] }
        @client.notifier.reset
      end

      if options[:save_as]
        write_runs(options[:save_as][0])
        write_counts(options[:save_as][1])
      end
    end

    # Called inside a run to collect a stat you want with the given count.
    # The stat should be a string or symbol, and count should be a number (or float).
    def sample(stat,count)
      cur_run[stat] ||= Sampler.new(stat)
      cur_run[stat].sample(count)
    end

    # Called inside a run to do a count of a measurement.
    def count(stat,count=1)
      cur_count[stat] ||= 0
      cur_count[stat] += count
    end

    # Takes the samples for all runs and returns an array suitable for passing
    # to CSV or some other table output.  If you want to access the runs
    # directly then just use the Session#runs attribute.
    def runs_to_a(headers=false)
      keys = ["run"] + Sampler.keys
      results = []
      results << keys if headers

      @runs.length.times do |run|
        @runs[run].values.each {|stats| results << [run] + stats.values }
      end

      return results
    end

    # Takes the counts for all the runs and produces an array suitable
    # for CSV output.  Use Session#counts to access the counts directly.
    def counts_to_a(headers=false)
      keys = @counts[0].keys
      results = []
      results << ["run"] + keys if headers

      @counts.length.times do |run|
        results << [run]
        keys.each do |k|
          results.last << @counts[run][k]
        end
      end

      return results
    end

    # Lets you track some value you need to report on later.  Doesn't
    # do any calculations and is matched for each run.  You then access
    # Session#tracking which is an Array of runs, each run being a Hash.
    # Inside the hash is the tracking you registerd by {name => [val1, val2]}.
    def track(name,value)
      @tracking.last[name] ||= []
      @tracking.last[name] << value
    end

    # Writes the runs to the given file as a CSV.
    def write_runs(file)
      CSV.open(file,"w") {|out| runs_to_a(headers=true).each {|r| out << r } }
    end

    # Writes the counts to the given file as a CSV.
    def write_counts(file)
      CSV.open(file,"w") {|out| counts_to_a(headers=true).each {|c| out << c } }
    end

    # Used inside Session#run to wrap an attempted request or potentially
    # failing action and then count the exceptions thrown.
    def count_errors(as)
      begin
        yield
      rescue 
        count as
        count $!.class.to_s.tr(":","")
      end
    end
  end
end
