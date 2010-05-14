shared_examples_for "redirectable" do

  before :all do
    @uri = "http://example.org:4567/answers/answer.xml"
    @redirect = "http://example.com/answer"
  end

  it "raises a RedirectionError when Location field-value missed" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
    http(@request.uri)
    stub_response(@code, "GO AWAY")
    lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
  end

  it "raises a RedirectionError when redirection level too deep" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)

    http(@request.uri)
    (@request.limit - 1).times do
      stub_response(@code, "GO AWAY", "Location" => @redirect)
      http(@redirect)
    end
    stub_response(@code, "GO AWAY", "Location" => @redirect)

    lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
  end

end

# EOF