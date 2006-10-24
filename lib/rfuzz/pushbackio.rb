require 'stringio'

module RFuzz
  # A simple class that using a StringIO object internally to allow for faster
  # and simpler "push back" semantics.  It basically lets you read a random
  # amount from a secondary IO object, parse what is needed, and then anything
  # remaining can be quickly pushed back in one chunk for the next read.
  class PushBackIO
    attr_accessor :secondary

    def initialize(secondary)
      @secondary = secondary
      @buffer = StringIO.new
      @die_after = rand($io_death_count) if $io_death_count
    end

    # Pushes the given string content back onto the stream for the 
    # next read to handle.
    def push(content)
      if content.length > 0
        @buffer.write(content)
      end
    end

    def pop(n)
      @buffer.rewind
      @buffer.read(n) || ""
    end

    def reset
      @buffer.string = @buffer.read  # reset out internal buffer
    end

    # First does a read from the internal buffer, and then appends anything
    # needed from the secondary IO to complete the request.  The return 
    # value is guaranteed to be a String, and never nil.  If it returns
    # a string of length 0 then there is nothing to read from the buffer (most
    # likely closed).  It will also avoid reading from a secondary that's closed.
    #
    # If partial==true then readpartial is used instead.
    def read(n, partial=false)
      r = pop(n)
      needs = n - r.length

      if needs > 0
        sec = ""
        if partial
          begin
            protect do
              sec = @secondary.readpartial(needs) 
            end
          rescue EOFError
            close
          end
        else
          protect { sec = @secondary.read(needs)}
        end

        r << (sec || "")

        # finally, if there's nothing at all returned then this is bad
        if r.length == 0
          raise HttpClientError.new("Server returned empty response.")
        end
      end

      reset
      return r
    end

    def flush
      protect { @secondary.flush }
    end

    def write(content)
      protect { @secondary.write(content) }
    end

    def close
      @secondary.close rescue nil
    end

    def protect
      if !@secondary.closed?
        yield
      else
        raise HttpClientError.new("Socket closed.")
      end
    end
  end
end
