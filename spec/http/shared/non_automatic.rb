shared_examples_for "non-automatic unless GET/HEAD" do

  before :all do
    @uri = "http://example.org:4567/answers/answer.xml"
    @redirect = "http://example.com/answer"
  end

  it "follows the redirection when Location field-value exists and redirection allowed (GET/HEAD)" do
    [Net::HTTP::Get, Net::HTTP::Head].each do |verb|
      @request = SMG::HTTP::Request.new(verb, @uri)

      http(@request.uri)
      (@request.limit - 1).times do
        stub_response(@code, "GO AWAY", "Location" => @redirect)
        http(@redirect)
      end
      stub_response(200, "OK")

      @response = @request.perform
      @response.code.should == 200
      @response.message.should == "OK"
    end
  end

  it "raises a RedirectionError when redirection is not allowed (according to RFC)" do
    [Net::HTTP::Post, Net::HTTP::Put, Net::HTTP::Delete].each do |verb|
      @request = SMG::HTTP::Request.new(verb, @uri)
      http(@request.uri)
      stub_response(@code, "GO AWAY", "Location" => @redirect)
      lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
    end
  end

end

# EOF