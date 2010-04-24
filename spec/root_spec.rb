require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, ".root" do

  before :each do
    @klass = Class.new { include SMG::Resource }
  end

  it "defines the root tag for further mapping" do
    @klass.root 'foo'
    @klass.extract 'a'
    @klass.mapping.elements.should have_key ['foo','a']
  end

  it "could be redefined on-the-fly" do
    @klass.root 'foo'
    @klass.extract 'a'
    @klass.root 'bar'
    @klass.extract 'b'
    @klass.mapping.elements.should have_key ['foo','a']
    @klass.mapping.elements.should have_key ['bar','b']
  end

end

# EOF