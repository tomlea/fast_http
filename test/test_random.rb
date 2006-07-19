# Copyright (c) 2006 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.

require 'test/unit'
require 'socket'
require 'rfuzz/random'

include RFuzz

class RandomGeneratorTest < Test::Unit::TestCase
  def setup
    @rand = RandomGenerator.new(open("resources/words.txt").read.split("\n"))
  end

  def test_headers
    h = @rand.headers(20,10)
    assert_equal 20,h.length, "wrong number of headers"

    [:words,:base64,:uris,:byte_array,:ints,:floats].each do |t|
      h = @rand.headers(20,10,type=t)
      assert_equal 20,h.length
    end

  end

  def test_queries
    q = @rand.queries(20,10)
    assert_equal 20,q.length, "wrong number of queries"

    [:base64,:uris,:byte_array,:ints,:floats].each do |t|
      q = @rand.queries(20,10,type=t)
      assert_equal 20,q.length
    end

  end

  def test_uris
    u = @rand.uris(20, 10)
    assert_equal 20,u.length,"wrong number of uris"
  end

  def test_words
    w = @rand.words(100)
    assert_equal 100,w.length,"wrong number of words"
  end

  def test_bytes
    b = @rand.bytes(100)
    assert_not_nil b
  end

  def test_base64
    b = @rand.base64(100,20)
    assert_not_nil b
    assert_equal 100,b.length
  end

  def test_num
    b1 = @rand.num(100)
    assert_not_nil b1
    assert b1 < 100, "returned by greater than 10"
  end

  def test_ints
    i = @rand.ints(100)
    assert_equal 100, i.length, "wrong length"
  end

  def test_floats
    f = @rand.floats(100)
    assert_equal 100, f.length, "wrong length"
  end

end

