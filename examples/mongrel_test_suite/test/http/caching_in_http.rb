require 'rfuzz/session'

context "13: Caching in HTTP" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

  specify "13.1.1: Cache Correctness" do
  end


  specify "13.1.2: Warnings" do
  end


  specify "13.1.3: Cache-control Mechanisms" do
  end


  specify "13.1.4: Explicit User Agent Warnings" do
  end


  specify "13.1.5: Exceptions to the Rules and Warnings" do
  end


  specify "13.1.6: Client-controlled Behavior" do
  end


  specify "13.2: Expiration Model" do
  end


  specify "13.2.1: Server-Specified Expiration" do
  end


  specify "13.2.2: Heuristic Expiration" do
  end


  specify "13.2.3: Age Calculations" do
  end


  specify "13.2.4: Expiration Calculations" do
  end


  specify "13.2.5: Disambiguating Expiration Values" do
  end


  specify "13.2.6: Disambiguating Multiple Responses" do
  end


  specify "13.3: Validation Model" do
  end


  specify "13.3.1: Last-Modified Dates" do
  end


  specify "13.3.2: Entity Tag Cache Validators" do
  end


  specify "13.3.3: Weak and Strong Validators" do
  end


  specify "13.3.4: Rules for When to Use Entity Tags and Last-Modified Dates" do
  end


  specify "13.3.5: Non-validating Conditionals" do
  end


  specify "13.4: Response Cacheability" do
  end


  specify "13.5: Constructing Responses From Caches" do
  end


  specify "13.5.1: End-to-end and Hop-by-hop Headers" do
  end


  specify "13.5.2: Non-modifiable Headers" do
  end


  specify "13.5.3: Combining Headers" do
  end


  specify "13.5.4: Combining Byte Ranges" do
  end


  specify "13.6: Caching Negotiated Responses" do
  end


  specify "13.7: Shared and Non-Shared Caches" do
  end


  specify "13.8: Errors or Incomplete Response Cache Behavior" do
  end


  specify "13.9: Side Effects of GET and HEAD" do
  end


  specify "13.10: Invalidation After Updates or Deletions" do
  end


  specify "13.11: Write-Through Mandatory" do
  end


  specify "13.12: Cache Replacement" do
  end


  specify "13.13: History Lists" do
  end


end