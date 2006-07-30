require 'rfuzz/session'

context "11: Access Authentication" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

end