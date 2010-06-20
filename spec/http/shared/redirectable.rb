shared_examples_for "redirectable" do

  it "raises a RedirectionError when Location field-value missed" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
    http(@request.uri)
    stub_response(@code, "GO AWAY")
    lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
  end

  it "raises a RedirectionError when redirection level too deep" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :limit => 3)

    http(@request.uri)
    stub_response(@code, "GO AWAY", "Location" => @redirect)
    http(@redirect)
    stub_response(@code, "GO AWAY", "Location" => @redirect)
    http(@redirect)
    stub_response(@code, "GO AWAY", "Location" => @redirect)

    lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
  end

end

# EOF