# Implements the randomness engine for RFuzz
require 'base64'
require 'fuzzrnd'

module RFuzz
  class RandomGenerator

    # Either initialized without a word dictionary or with one.
    # If you initialize with a word dictionary then you can generate
    # the random words, and is the expected behavior.  You can use
    # the "type" parameter to change the default type of generated
    # content from words to any of the other types available 
    # [:base64,:uris,:byte_array,:ints,:floats].
    #
    # The dict should just be an array of words.
    def initialize(dict=nil, type=:words)
      # NOT meant to be secure so chill
      @rnd = FuzzRnd.new("#{self.inspect}")
      @dict = dict
      @type = type
    end

    # Returns a random hash of type (default :words) where
    # the key=>value is randomly generated.  This is aliased
    # for RandomGenerator.queries and RandomGenerator.headers
    # so that it is more readable.
    #
    # [:words,:base64,:uris,:byte_array,:ints,:floats] are the available
    # types of generated hash garbage you can use.  These "types" just
    # translate to function calls on self.send(type,length).
    def hash_of(count,length=5,type=@type)
      list = []
      count.times do
        list << Hash[*send(type,length*2)]
      end

      return list
    end
    alias :queries :hash_of
    alias :headers :hash_of

    # Generate an array of random length URIs based on words from the dict.
    # The default max length=100 and is the number of words to chain together
    # into a gigantor URI.  The URI starts with /.
    def uris(count,length=100)
      ulist = []
      count.times do
        ulist << "/" + words(num(length)).join("/").tr("'","")
      end
      return ulist
    end

    # Generates an array with count number of randomly selected
    # words from the dictionary.
    def words(count=1)
      raise "You need a dictionary." unless @dict
      w = ints(count, @dict.length)
      w.collect {|i| @dict[i]}
    end


    # Generates an array of base64 encoded chunks of garbage.
    # The length=100 is the default and is a max, but the lengths
    # are random.
    def base64(count,length=100)
      list = []
      count.times { 
        list << Base64.encode64(@rnd.data(num(length)))
      }
      return list
    end

    # Generates an array of garbage byte strings, these are
    # binary strings so very nasty.  As usual, length=100
    # is a max for the random lengths.
    def byte_array(count,length=100)
      list = []
      count.times { list << @rnd.data(num(length)) }
      return list
    end

    # Generate a single String with random binary garbage in it.
    def bytes(count)
      @rnd.data(count)
    end

    # A random number with a maximum of max.
    def num(max)
      ints(1, max)[0]
    end

    # An array of integers with a default max of max.
    # The integers are 4 bytes and pulled from network
    # encoding so they should be cross platform (meaning
    # tests should run the same on all platforms).
    def ints(count, max = nil)
      i = @rnd.data(count * 4).unpack("N*")
      if max
        i = i.collect {|i| i % max }
      end
      return i
    end

    # An array for random floats.
    def floats(count)
      @rnd.data(count * 8).unpack("G*")
    end
  end

end
