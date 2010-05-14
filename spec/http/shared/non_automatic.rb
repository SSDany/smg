shared_examples_for "non-automatic unless GET/HEAD" do

  before :all do
    @uri = "http://example.org:4567/answers/answer.xml"
    @redirect = "http://example.com/answer"
  end

  it "follows the redirection when Location field-value exists and redirection allowed (GET/HEAD)" do
    [Net::HTTP::Get, Net::HTTP::Head].each do |verb|
      @request = SMG::HTTP::Request.new(verb, @uri)
      http(@request.uri)
      http(@redirect, :times => @request.limit)
      @request.limit.times { stub_response(@code, "GO AWAY", "Location" => @redirect.to_s) }
      stub_response(200, "OK", "<answer>42</answer>")

      @response = @request.perform
      @response.code.should == 200
      @response.body.should == "<answer>42</answer>"
    end
  end

  it "raises a RedirectionError when redirection is not allowed (according to RFC)" do
    [Net::HTTP::Post, Net::HTTP::Put, Net::HTTP::Delete].each do |verb|
      @request = SMG::HTTP::Request.new(verb, @uri)
      http(@request.uri)
      stub_response(@code,"GO AWAY", "Location" => @redirect.to_s)
      lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
    end
  end

end

# EOF