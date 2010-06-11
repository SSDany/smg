shared_examples_for "automatic" do

  before :all do
    @uri = "http://example.org:4567/answers/answer.xml"
    @redirect = "http://example.com/answer"
  end

  it "follows the redirection when Location field-value exists" do
    SMG::HTTP::Request::VERBS.each do |verb|
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

  it "uses GET method" do
    SMG::HTTP::Request::VERBS.each do |verb|
      @request = SMG::HTTP::Request.new(verb, @uri)

      http(@request.uri)
      stub_response(@code, "GO AWAY", "Location" => @redirect)
      http(@redirect)
      stub_response(200, "OK")

      @response = @request.perform
      @request.verb.should == Net::HTTP::Get
      @response.code.should == 200
      @response.message.should == "OK"
    end
  end

end

# EOF