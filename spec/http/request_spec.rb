require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

require SPEC_ROOT + 'http/shared/redirectable'
require SPEC_ROOT + 'http/shared/non_automatic'
require SPEC_ROOT + 'http/shared/automatic'

describe SMG::HTTP::Request, "instantiation" do

  before :all do
    @uri = "http://example.org:4567/answers/answer.xml?api_key=APIKEY"
  end

  it "constructs a valid uri" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
    @request.uri.to_s.should  == @uri.to_s
    @request.uri.host.should  == "example.org"
    @request.uri.port.should  == 4567
    @request.uri.path.should  == "/answers/answer.xml"
    @request.uri.query.should == "api_key=APIKEY"
  end

  it "respects :headers option" do
    headers = {"Accept-Encoding" => "gzip,deflate,*;q=0"}
    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri, :headers => headers)
    @request.headers.should == {"Accept-Encoding" => "gzip,deflate,*;q=0"}
  end

  it "respects :no_follow and :limit options" do
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

  it "respects :body option" do
    @request = SMG::HTTP::Request.new(Net::HTTP::Post, @uri, :body => "<answer>42</answer>")
    @request.body.should == "<answer>42</answer>"
  end

end

describe SMG::HTTP::Request, "#perform" do

  include Spec::Helpers::HTTPHelpers

  SMG::HTTP::Request::VERBS.each do |verb|
    describe "with #{verb}" do

      before :all do
        @uri = "http://example.org:4567/answers/answer.xml?api_key=APIKEY"
      end

      before :each do
        @request = SMG::HTTP::Request.new(verb, @uri)
        http(@request.uri)
      end

      it "raises a ConnectionError when receiving an 'error' response code" do
        stub_response(403, "GO AWAY")
        lambda { @request.perform }.should raise_error(
        SMG::HTTP::ConnectionError, %r{Action failed with code: 403. Message: GO AWAY})
      end

      it "returns response otherwise" do
        stub_response(200, "OK", "<answer>42</answer>")
        @response = @request.perform
        @response.code.should == 200
        @response.message.should == "OK"
        @response.body.should == "<answer>42</answer>"
      end

    end
  end

  it "raises an SMG::HTTP::TimeoutError on timeouts" do
    @uri = Addressable::URI.parse("http://example.org")
    @http = mock('http')

    Net::HTTP.should_receive(:start).
    with(@uri.host, @uri.port).once.
    and_raise(Timeout::Error.new("connection timeout")) # we should not re-test Net::HTTP timeouts

    @request = SMG::HTTP::Request.new(Net::HTTP::Get, @uri)
    lambda { @request.perform }.should raise_error SMG::HTTP::TimeoutError, %r{connection timeout}
  end

  [300,301,302,303,307].each do |code|
    describe "with #{code} redirection" do
      before(:all) { @code = code }
      it_should_behave_like "redirectable"
      it_should_behave_like code == 303 ? "automatic" : "non-automatic unless GET/HEAD"
    end
  end

end

# EOF