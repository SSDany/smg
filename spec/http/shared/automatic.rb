shared_examples_for "automatic" do

  before :all do
    @uri = "http://example.org:4567/answers/answer.xml"
    @redirect = "http://example.com/answer"
  end

  it "follows the redirection when Location field-value exists" do
    SMG::HTTP::Request::VERBS.each do |verb|
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

  it "uses GET method" do
    SMG::HTTP::Request::VERBS.each do |verb|
      @request = SMG::HTTP::Request.new(verb, @uri)
      http(@request.uri)
      http(@redirect)
      stub_response(@code, "GO AWAY", "Location" => @redirect.to_s)
      stub_response(200, "OK", "<answer>42</answer>")

      @response = @request.perform
      @request.verb.should == Net::HTTP::Get
      @response.code.should == 200
      @response.body.should == "<answer>42</answer>"
    end
  end

end

# EOF