# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/unit'
require 'rfuzz/stats'
require 'stringio'

include RFuzz

class SamplerTest < Test::Unit::TestCase

  def test_sampling_speed
    out = StringIO.new

    s = Sampler.new("test")
    t = Sampler.new("time")
    m = Sampler.new("mark")

    m.mark
    100.times { s.sample(rand(20)); t.tick }
    m.tick

    s.dump("FIRST", out)
    t.dump("FIRST", out)
    
    old_mean = s.mean
    old_sd = s.sd

    s.reset
    t.reset
    m.mark
    100.times { s.sample(rand(30)); t.tick }
    m.tick
    
    s.dump("SECOND", out)
    t.dump("SECOND", out)
    t.dump("MARK",out)
    assert_not_equal old_mean, s.mean
    assert_not_equal old_mean, s.sd    
  end

end
