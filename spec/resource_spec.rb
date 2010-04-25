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

  describe "#parsed?" do

    it "returns true if resource was build by .parse method" do
      resource = @klass.parse("<somexml/>")
      resource.should be_parsed
    end

    it "returns false otherwise" do
      resource = @klass.new
      resource.should_not be_parsed
    end

  end

end

# EOF