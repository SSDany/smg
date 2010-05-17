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

# EOF