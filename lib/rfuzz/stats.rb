# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

# A very simple little class for doing some basic fast statistics sampling.
# You feed it either samples of numeric data you want measured or you call
# Sampler.tick to get it to add a time delta between the last time you called it.
# When you're done either call sum, sumsq, n, min, max, mean or sd to get 
# the information.  The other option is to just call dump and see everything.
#
# It does all of this very fast and doesn't take up any memory since the samples
# are not stored but instead all the values are calculated on the fly.
module RFuzz
  class Sampler
    attr_reader :sum, :sumsq, :n, :min, :max

    def initialize(name)
      @name = name
      reset
    end

    # Resets the internal counters so you can start sampling again.
    def reset
      @sum = 0.0
      @sumsq = 0.0
      @last_time = Time.new
      @n = 0.0
      @min = 0.0
      @max = 0.0
    end

    # Adds a sampling to the calculations.
    def sample(s)
      @sum += s
      @sumsq += s * s
      if @n == 0
        @min = @max = s
      else
        @min = s if @min > s
        @max = s if @max < s
      end
      @n+=1
    end

    # Dump this Sampler object with an optional additional message.
    def dump(msg = "", out=STDERR)
      out.puts "#{msg}: #{self.to_s}"
    end

    # Returns a common display (used by dump)
    def to_s  
    "[%s]: SUM=%0.6f, SUMSQ=%0.6f, N=%0.6f, MEAN=%0.6f, SD=%0.6f, MIN=%0.6f, MAX=%0.6f" % values
    end

    # An array of the values minus the name: [sum,sumsq,n,mean,sd,min,max]
    def values
      [@name, @sum, @sumsq, @n, mean, sd, @min, @max]
    end

    # Class method that returns the headers that a CSV file would have for the
    # values that this stats object is using.
    def self.keys
      ["name","sum","sumsq","n","mean","sd","min","max"]
    end

    def to_hash
      {"name" => @name, "sum" => @sum, "sumsq" => @sumsq, "mean" => mean,
        "sd" => sd, "min" => @min, "max" => @max}
    end

    # Calculates and returns the mean for the data passed so far.
    def mean
      @sum / @n
    end

    # Calculates the standard deviation of the data so far.
    def sd
      # (sqrt( ((s).sumsq - ( (s).sum * (s).sum / (s).n)) / ((s).n-1) ))
      begin
        return Math.sqrt( (@sumsq - ( @sum * @sum / @n)) / (@n-1) )
      rescue Errno::EDOM
        return 0.0
      end
    end

    # You can just call tick repeatedly if you need the delta times
    # between a set of sample periods, but many times you actually want
    # to sample how long something takes between a start/end period.
    # Call mark at the beginning and then tick at the end you'll get this
    # kind of measurement.  Don't mix mark/tick and tick sampling together
    # or the measurement will be meaningless.
    def mark
      @last_time = Time.now
    end

    # Adds a time delta between now and the last time you called this.  This
    # will give you the average time between two activities.
    # 
    # An example is:
    #
    #  t = Sampler.new("do_stuff")
    #  10000.times { do_stuff(); t.tick }
    #  t.dump("time")
    #
    def tick
      now = Time.now
      sample(now - @last_time)
      @last_time = now
    end
  end

  # When registered as the notifier for a client it tracks
  # the times for each part of the request.  Rather than subclassing
  # RFuzz::Notifier it uses a method_missing to record the even timings.
  # 
  # You can dump it with to_s, or you can access the StatsTracker.stats
  # hash to read the RFuzz::Sampler objects related to each event.
  class StatsTracker
    attr_reader :stats

    def initialize
      @stats = {}
      @error_count = 0
    end

    def mark(event)
      @stats[event] ||= RFuzz::Sampler.new(event)
      @stats[event].mark
    end

    def sample(event)
      @stats[event].tick
    end

    def reset
      @stats.each {|e,s| s.reset }
    end

    def method_missing(event, *args)
      case args[0]
      when :begins
        mark(:request) if event == :connect
        mark(event)
      when :ends
        sample(:request) if event == :close
        sample(event)
      when :error
        sample(:request)
        @error_count += 1
      end
    end

    def to_s
      "#{@stats.values.join("\n")}\nErrors: #@error_count"
    end
  end
end
