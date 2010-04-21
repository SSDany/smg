require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, ".parse" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/malus.xml')
  end

  it "respects context" do

      @klass.root 'spec'

      @klass.extract :order         , :context => [:preview, :full]
      @klass.extract :family        , :context => [:preview, :full]
      @klass.extract :genus         , :context => [:preview, :full]
      @klass.extract :binomial      , :context => [:preview, :full]
      @klass.extract :conservation  , :context => [:full]

      malus = @klass.parse(@data,:preview)
      malus.genus.should == "Malus"
      malus.conservation.should be_nil

      malus = @klass.parse(@data,:full)
      malus.genus.should == "Malus"
      malus.conservation.should == "Vulnerable (IUCN 2.3)"

  end

end

# EOF