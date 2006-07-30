require 'rfuzz/session'

context "15: Security Considerations" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

  specify "15.1: Personal Information" do
  end


  specify "15.1.1: Abuse of Server Log Information" do
  end


  specify "15.1.2: Transfer of Sensitive Information" do
  end


  specify "15.1.3: Encoding Sensitive Information in URI's" do
  end


  specify "15.1.4: Privacy Issues Connected to Accept Headers" do
  end


  specify "15.2: Attacks Based On File and Path Names" do
  end


  specify "15.3: DNS Spoofing" do
  end


  specify "15.4: Location Headers and Spoofing" do
  end


  specify "15.5: Content-Disposition Issues" do
  end


  specify "15.6: Authentication Credentials and Idle Clients" do
  end


  specify "15.7: Proxies and Caching" do
  end


  specify "15.7.1: Denial of Service Attacks on Proxies" do
  end
end
