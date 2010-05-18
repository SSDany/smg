require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::HTTP::Model, ".uri_for" do

  before :all do
    @klass = Class.new { include SMG::Resource, SMG::HTTP }
    @klass.site "http://www.example.org"
    @klass.params "developer" => "Valve"
  end

  it "appends a path to the base URI" do
    uri = @klass.send(:uri_for, "search")
    uri.host.should == "www.example.org"
    uri.path.should == "/search"
    uri.query_values.should == {"developer" => "Valve"}
  end

  it "appends a query to the base URI" do
    uri = @klass.send(:uri_for, "search", {"cake" => "Lie"})
    uri.host.should == "www.example.org"
    uri.path.should == "/search"
    uri.query_values.should == {"developer" => "Valve", "cake" => "Lie"}
  end

end

describe SMG::HTTP::Model do

  before :all do
    @klass = Class.new { include SMG::Resource, SMG::HTTP }
    @klass.site "http://www.example.org"
    @klass.params "developer" => "Valve"
    @klass.extract "game/name"
  end

  Hash[[:get, :post, :put, :delete, :head].zip(SMG::HTTP::Request::VERBS)].each do |sym,verb|
    describe ".#{sym}" do

      before :each do
        @response = Net::HTTPOK.new('1.1', 200, "OK")
        @response.stub!(:body).and_return("<game><name>Portal</name></game>")
      end

      before :each do
        @request = mock('request')
        @request.stub!(:perform).and_return(@response)
      end

      before :each do
        @headers = {"Accept-Encoding" => "gzip,deflate;*;q=0"}
        @options = {:query => {"cake" => "LIE"}, :headers => @headers}
        SMG::HTTP::Request.should_receive(:new).
        with(verb, instance_of(Addressable::URI), {:headers => @headers}).
        and_return(@request)
      end

      it "performs #{sym.to_s.upcase} request" do
        @klass.send(sym, "game", @options)
      end

      it "parses response' body when no block given" do
        @game = @klass.send(sym, "game", @options)
        @game.name.should == "Portal"
      end

      it "yields response and parses the block returning value when block given" do
        @game = @klass.send(sym, "game", @options) { |response| "<game><name>Portal2</name></game>" }
        @game.name.should == "Portal2"
      end

    end
  end

end

# EOF