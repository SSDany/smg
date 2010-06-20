require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

require SPEC_ROOT + 'http/shared/redirectable'

describe SMG::HTTP::Request do

  before :all do
    @uri = "http://example.org:4567/answers/answer.xml?api_key=APIKEY"
  end

  it "exposes uri" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
    @request.uri.to_s.should  == @uri
    @request.uri.host.should  == "example.org"
    @request.uri.port.should  == 4567
    @request.uri.path.should  == "/answers/answer.xml"
    @request.uri.query.should == "api_key=APIKEY"
  end

  it "exposes headers" do
    headers = {"Accept-Encoding" => "gzip,deflate,*;q=0"}
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :headers => headers)
    @request.headers.should == {"Accept-Encoding" => "gzip,deflate,*;q=0"}
  end

  it "defaults :limit to 5" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
    @request.limit.should == 5
  end

  it "uses :no_follow and :limit options when provided" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :no_follow => true)
    @request.limit.should == 1
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :no_follow => false)
    @request.limit.should == 5
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
    @request.limit.should == 5
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :limit => 10)
    @request.limit.should == 10
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :no_follow => true, :limit => 10)
    @request.limit.should == 1
  end

  describe "when :body provided" do

    it "exposes body" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Post, @uri, :body => "<answer>42</answer>")
      @request.body.should == "<answer>42</answer>"
    end

    it "uses body" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Post, @uri, :body => "<answer>42</answer>")
      @request.send(:setup)
      @request.instance_variable_get(:@request).body.should == "<answer>42</answer>"
    end

  end

  describe "when :proxy provided" do
    include Spec::Helpers::HTTPHelpers

    before :each do
      @request = SMG::HTTP::Request.new(Net::HTTP::Post, @uri, :proxy => "http://yoyo:5576537@example.com:6789")
    end

    it "exposes proxy" do
      @request.proxy.to_s.should == "http://yoyo:5576537@example.com:6789"
      @request.proxy.host.should == "example.com"
      @request.proxy.port.should == 6789
      @request.proxy.user.should == "yoyo"
      @request.proxy.password.should == "5576537"
    end

    it "uses proxy" do
      http = @request.send(:http)
      http.should be_proxy
      http.proxy_address.should == "example.com"
      http.proxy_port.should == 6789
      http.proxy_user.should == "yoyo"
      http.proxy_pass.should == "5576537"
    end

  end

  describe "when :timeout provided" do
    include Spec::Helpers::HTTPHelpers

    it "defines both open and read timeouts" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :timeout => 42)
      http = @request.send(:http)
      http.open_timeout.should == 42
      http.read_timeout.should == 42
    end

    it "raises an SMG::HTTP::TimeoutError on timeouts" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
      http(@request.uri).should_receive(:request).
      with(instance_of(Net::HTTP::Get)).
      and_raise(Timeout::Error.new("connection timeout"))

      lambda { @request.perform }.
      should raise_error SMG::HTTP::TimeoutError, %r{connection timeout}
    end

  end

end

describe SMG::HTTP::Request, "#perform" do
  include Spec::Helpers::HTTPHelpers

  SMG::HTTP::Request::VERBS.each do |verb|
    describe "when HTTP method is #{verb}" do

      it "raises a ConnectionError when receiving an 'error' response code" do
        @request = SMG::HTTP::Request.new(verb, "http://example.org")
        http(@request.uri)
        stub_response(403, "GO AWAY")
        lambda { @request.perform }.should raise_error(
        SMG::HTTP::ConnectionError, %r{Action failed with code: 403. Message: GO AWAY})
      end

      it "returns response otherwise" do
        @request = SMG::HTTP::Request.new(verb, "http://example.org")
        http(@request.uri)
        stub_response(200, "OK", "<answer>42</answer>")
        @response = @request.perform
        @response.code.should == 200
        @response.message.should == "OK"
        @response.body.should == "<answer>42</answer>"
      end

    end
  end

end

describe SMG::HTTP::Request, "#perform with redirection" do
  include Spec::Helpers::HTTPHelpers

  before :all do 
    @uri = "http://example.org:4567/answers/answer.xml?api_key=APIKEY"
    @redirect = "http://yoyo:5576537@example.com:6789"
  end

  [300,301,302,307].each do |code|
    describe code do

      before :all do
        @code = code
        @allowed = Net::HTTP::Get, Net::HTTP::Head
      end

      it_should_behave_like "redirectable"

      it "follows the redirection when Location field-value exists and redirection allowed (GET/HEAD)" do
        @allowed.each do |verb|
          @request = SMG::HTTP::Request.new(verb, @uri, :limit => 3)

          http(@request.uri)
          stub_response(@code, "GO AWAY", "Location" => @redirect)
          http(@redirect)
          stub_response(@code, "GO AWAY", "Location" => @redirect)
          http(@redirect)
          stub_response(200, "OK")

          @request.verb.should == verb
          @response = @request.perform
          @response.code.should == 200
          @response.message.should == "OK"
        end
      end

      it "raises a RedirectionError when redirection is not allowed (according to RFC)" do
        (SMG::HTTP::Request::VERBS - @allowed).each do |verb|
          @request = SMG::HTTP::Request.new(verb, @uri)
          http(@request.uri)
          stub_response(@code, "GO AWAY", "Location" => @redirect)
          lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
        end
      end

    end
  end

  describe 303 do

    before :all do
      @code = 303
    end

    it_should_behave_like "redirectable"

    it "follows the redirection when Location field-value exists" do
      SMG::HTTP::Request::VERBS.each do |verb|
        @request = SMG::HTTP::Request.new(verb, @uri, :limit => 3)

        http(@request.uri)
        stub_response(@code, "GO AWAY", "Location" => @redirect)
        http(@redirect)
        stub_response(@code, "GO AWAY", "Location" => @redirect)
        http(@redirect)
        stub_response(200, "OK")

        @response = @request.perform
        @response.code.should == 200
        @response.message.should == "OK"
      end
    end

    it "switches to the GET method" do
      SMG::HTTP::Request::VERBS.each do |verb|
        @request = SMG::HTTP::Request.new(verb, @uri, :limit => 3)

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

  describe 305 do

    it "attempts to repeat request via proxy using the same HTTP method" do
      SMG::HTTP::Request::VERBS.each do |verb|
        @request = SMG::HTTP::Request.new(verb, @uri, :limit => 3)

        http(@request.uri)
        stub_response(305, "GO AWAY", "Location" => @redirect)
        http(@request.uri, @redirect)
        stub_response(200, "OK")

        @request.verb.should == verb
        @response = @request.perform
        @request.verb.should == verb
        @response.code.should == 200
        @response.message.should == "OK"
      end
    end

    it "raises a RedirectionError when Location field-value missed" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :limit => 3)
      http(@request.uri)
      stub_response(305, "GO AWAY")
      lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
    end

    it "raises a RedirectionError when redirection level too deep" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :limit => 3)

      http(@request.uri)
      stub_response(305, "GO AWAY", "Location" => @redirect)
      http(@request.uri, @redirect)
      stub_response(305, "GO AWAY", "Location" => @redirect)
      http(@request.uri, @redirect)
      stub_response(305, "GO AWAY", "Location" => @redirect)

      lambda { @request.perform }.should raise_error SMG::HTTP::RedirectionError
    end

  end

end

describe SMG::HTTP::Request do
  include Spec::Helpers::HTTPHelpers

  it "uses SSL for HTTPS scheme" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, "https://example.org:4567")
    @request.should be_ssl
    @request.send(:http).use_ssl?.should == true
  end

  it "does not use SSL otherwise" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, "http://example.org:4567")
    @request.should_not be_ssl
    @request.send(:http).use_ssl?.should == false
  end

  describe "when SSL enabled" do

    before :all do
      @cert = mock("certificate")
      @pkey = mock("pkey")
    end

    before :each do
      @http = Net::HTTP.new("https://example.org")
      Net::HTTP.should_receive(:new).and_return(@http)
    end

    it "uses PEM certificate when provided" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Get, "https://example.org", :pem => :test)
      OpenSSL::X509::Certificate.should_receive(:new).with(:test).and_return(@cert)
      OpenSSL::PKey::RSA.should_receive(:new).with(:test).and_return(@pkey)
      @request.send(:http)
      @http.cert.should == @cert
      @http.key.should == @pkey
      @http.verify_mode.should == OpenSSL::SSL::VERIFY_PEER
    end

    it "defaults verify mode to VERIFY_NONE otherwise" do
      @request = SMG::HTTP::Request.new(Net::HTTP::Get, "https://example.org")
      @http.should_receive(:use_ssl=).with(true)
      @http.should_not_receive(:cert=)
      @http.should_not_receive(:key=)
      @request.send(:http)
      @http.verify_mode.should == OpenSSL::SSL::VERIFY_NONE
    end

  end

  it "does not use PEM certificate when SSL disabled" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, "http://example.org", :pem => :test)
    @http = Net::HTTP.new("http://example.org")
    Net::HTTP.should_receive(:new).and_return(@http)
    @http.should_not_receive(:cert=)
    @http.should_not_receive(:key=)
    @http.should_not_receive(:verify_mode=)
    @request.send(:http)
  end

end

# EOF