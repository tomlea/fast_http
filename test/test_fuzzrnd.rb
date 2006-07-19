# Copyright (c) 2006 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.

require 'test/unit'
require 'fuzzrnd'

include RFuzz

class FuzzRndTest < Test::Unit::TestCase
  
  def test_seed_data
    fr = FuzzRnd.new("TEST SEED")
    d1 = fr.data(100)
    assert_equal 100, d1.length, "wrong length"

    d2 = fr.seed("TEST SEED").data(100)
    assert_equal 100, d2.length, "wrong length"

    assert_equal d1,d2, "same keys should produce same random"
  end


  def test_gen_numbers
    fr = FuzzRnd.new("TEST SEED")
    ints = fr.data(100 * 4).unpack("N*")
    assert_equal 100,ints.length, "didn't get 100 ints"

    floats = fr.data(50 * 8).unpack("G*")
    assert_equal 50,floats.length, "didn't get 50 floats"
  end
end
