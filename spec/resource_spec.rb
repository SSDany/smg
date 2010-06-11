require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Resource do

  before :each do
    @klass = Class.new { include SMG::Resource }
  end

  describe "when included" do

    it "extends class with the SMG::Model" do
      @klass.should be_an SMG::Model
    end

  end

  describe "#parsed!" do

    it "marks resource as parsed" do
      resource = @klass.new
      resource.should_not be_parsed
      resource.parsed!
      resource.should be_parsed
    end

  end

end

# EOF