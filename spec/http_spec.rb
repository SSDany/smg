require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::HTTP::Model do

  before :all do
    @klass = Class.new {
      include SMG::Resource
      include SMG::HTTP
      params "term" => "Portal"
      site "http://store.steampowered.com"
    }
  end

  describe "#uri_for" do

    it "appends a path to the base URI" do
      uri = @klass.send(:uri_for, "search")
      uri.host.should == "store.steampowered.com"
      uri.path.should == "/search"
      uri.query_values.size.should == 1
      uri.query_values["term"].should == "Portal"
    end

    it "appends a query to the base URI" do
      uri = @klass.send(:uri_for, "search", {"cake" => "Lie"})
      uri.host.should == "store.steampowered.com"
      uri.path.should == "/search"
      uri.query_values.size.should == 2
      uri.query_values["term"].should == "Portal"
      uri.query_values["cake"].should == "Lie"
    end

  end

  SMG::HTTP::VERBS.each do |verb,klass|
    it "proxy #{verb} to #http" do
      @klass.should_receive(:http).with(verb, "/search", :options).and_return(:result)
      @klass.send(verb, "/search", :options).should == :result
    end
  end

end

describe SMG::HTTP::Model, "#http" do

  before :all do
    @klass = Class.new {
      include SMG::Resource
      include SMG::HTTP
      site "http://www.example.org"
    }
  end

  SMG::HTTP::VERBS.each do |verb,klass|
    describe "when HTTP method is #{verb.to_s.upcase}" do

      before :each do
        @response = mock("response", :body => "<response/>")
        @request = mock("request", :perform => @response)
      end

      it "creates a proper SMG::HTTP::Request" do
        SMG::HTTP::Request.should_receive(:new).with(klass, anything, anything).and_return(@request)
        @klass.send(:http, verb, "/search")
      end

      it "creates an SMG::HTTP::Request with proper URI" do
        @addressable = Addressable::URI.parse("http://www.example.org/path?qvalues=whatever")
        SMG::HTTP::Request.should_receive(:new).with(anything, @addressable, anything).and_return(@request)
        @klass.send(:http, verb, "/path", :query => {:qvalues => "whatever"})
      end

      it "creates an SMG::HTTP::Request with proper options" do
        @headers = {"X-Test" => "true"}.freeze
        SMG::HTTP::Request.should_receive(:new).with(anything, anything, :headers => @headers).and_return(@request)
        @klass.send(:http, verb, "/path", :query => {:qvalues => "whatever"}, :headers => @headers)
      end

      it "attempts to parse response' body" do
        SMG::HTTP::Request.should_receive(:new).with(any_args).and_return(@request)
        @klass.should_receive(:parse).with("<response/>").and_return(:resource)
        @klass.send(:http, verb, "/path").should == :resource
      end

    end
  end

end

# EOF