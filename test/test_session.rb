# Copyright (c) 2006 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.

require 'test/unit'
require 'rfuzz/session'
include RFuzz

class SessionTest < Test::Unit::TestCase

  def test_simple_session
    s = Session.new :host => "localhost", :port => 3001
    s.run 3, :save_as => ["test/runs.csv","test/counts.csv"] do |c,r|
      len = r.num(10) + 1
      s.count :len, len
      uris = r.uris(10,len)

      uris.each do |u| 
        s.count_errors(:legal) do
          # first sample for legal uris
          resp = c.get(u)
          s.count resp.http_status
          s.track :status, resp.http_status
        end
      end
    end

    assert_equal 3, s.tracking.length
    assert File.exist?("test/runs.csv")
    assert File.exist?("test/counts.csv")
    File.unlink "test/counts.csv"
    File.unlink "test/runs.csv"
  end
end
