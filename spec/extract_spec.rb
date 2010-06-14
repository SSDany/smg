require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, ".extract" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/malus.xml')
  end

  include Spec::Matchers::HaveInstanceMethodMixin

  it "defines appropriate reader and writer" do
    @klass.extract :whatever
    @klass.should have_instance_method :whatever
    @klass.should have_instance_method :whatever=
  end

  it "never overrides readers" do
    @klass.class_eval "def kingdom; return @kingdom.to_s.upcase; end"
    @klass.root 'spec'
    @klass.extract :kingdom
    malus = @klass.parse(@data)
    malus.kingdom.should == "PLANTAE"
    malus.instance_variable_get(:@kingdom).should == "Plantae"
  end

  it "never overrides writers" do
    @klass.class_eval "def kingdom=(value); @kingdom = value.to_s.upcase; end"
    @klass.root 'spec'
    @klass.extract :kingdom
    malus = @klass.parse(@data)
    malus.kingdom.should == "PLANTAE"
    malus.instance_variable_get(:@kingdom).should == "PLANTAE"
  end

  it "extracts an empty String if there's an empty element" do
    @klass.root 'spec'
    @klass.extract :additional
    malus = @klass.parse(@data)
    malus.additional.should == ""
  end

  it "extracts nothing if there's no appropriate element" do
    @klass.root 'spec'
    @klass.extract :bogus
    malus = @klass.parse(@data)
    malus.bogus.should == nil
  end

  it "extracts the text of an element otherwise" do
    @klass.root 'spec'
    @klass.extract :genus
    malus = @klass.parse(@data)
    malus.should respond_to :genus
    malus.should respond_to :genus=
    malus.genus.should == 'Malus'
  end

  describe "using :at option" do

    it "extracts the appropriate attribute" do
      @klass.extract 'spec/conservation', :as => :conservation_code, :at => :code
      malus = @klass.parse(@data)
      malus.conservation_code.should == 'VU'
    end

    it "extracts nothing if there'no appropriate attribute" do
      @klass.extract 'spec/conservation', :as => :conservation_code, :at => :bogus
      malus = @klass.parse(@data)
      malus.conservation_code.should == nil
    end

    it "extracts nothing if there'no appropriate element" do
      @klass.extract 'spec/whatever', :as => :whatever, :at => :bogus
      malus = @klass.parse(@data)
      malus.whatever.should == nil
    end

  end

  describe "using :as option" do

    it "defines appropriate reader and writer" do
      @klass.extract 'spec/conservation', :as => :conservation_status
      malus = @klass.parse(@data)
      malus.should respond_to :conservation_status
      malus.should respond_to :conservation_status=
    end

    it "extracts data from an element using the 'as' accessor" do
      @klass.extract 'spec/conservation', :as => :conservation_status
      malus = @klass.parse(@data)
      malus.conservation_status.should == 'Vulnerable (IUCN 2.3)'
    end

    it "extracts nothing if there's no appropriate element" do
      @klass.extract 'spec/bogus', :as => :conservation_code, :at => :bogus
      malus = @klass.parse(@data)
      malus.conservation_code.should == nil
    end

  end

  describe "using :class option" do

    describe "when :class represents an SMG::Resource" do

      it "extracts data into the class (AKA has_one)" do
        @foo = Class.new
        @foo.send(:include, SMG::Resource)
        @foo.root 'description'
        @foo.extract :common
        @foo.extract :described_by
        @foo.extract :described_as
        @foo.extract :described_at
        @klass.extract 'spec/description' , :as => :description, :class => @foo
        malus = @klass.parse(@data)
        malus.description.should be_an_instance_of @foo
        malus.description.common.should == "Asian Wild Apple"
        malus.description.described_at.should == "1983"
        malus.description.described_by.should == "Carl Friedrich von Ledebour"
        malus.description.described_as.should == "Pyrus sieversii"
      end

    end

    describe "when :class represents a built-in typecast" do

      it "makes an attempt to perform a typecast" do
        Class.new { include SMG::Resource }
        @klass.root 'spec'
        @klass.extract :conservation, :at => :year, :class => :integer, :as => :year_of_conservation_check
        malus = @klass.parse(@data)
        malus.year_of_conservation_check.should == 2007
      end

      it "raises an ArgumentError if typecasting fails" do
        Class.new { include SMG::Resource }
        @klass.root 'spec'
        @klass.extract :conservation, :at => :year, :class => :datetime, :as => :year_of_conservation_check
        lambda { @klass.parse(@data) }.
        should raise_error ArgumentError, %r{"2007" is not a valid source for :datetime} 
      end

    end

  end

end

describe SMG::Model, ".extract" do

  describe "when XML contains two or more suitable elements" do

    before :each do
      @klass = Class.new { include SMG::Resource }
      @data = File.read(FIXTURES_DIR + 'fake/valve.xml')
    end

    it "ignores everything except the first one suitable thing" do
      @klass.extract "games/game", :as => :title
      parsed = @klass.parse(@data)
      parsed.title.should == "Half-Life 2"
    end

    describe "using :at option" do

      it "ignores everything except the first one suitable thing" do
        @klass.extract "games/game", :at => :AppID, :as => :steam_application_id, :class => :integer
        parsed = @klass.parse(@data)
        parsed.steam_application_id.should == 220
      end

    end

    describe "using :class option, when :class option represents an SMG::Resource" do

      it "ignores everything except the first one suitable thing" do
        @game = Class.new { include SMG::Resource }
        @game.extract :game, :at => "AppID", :as => :steam_application_id, :class => :integer
        @game.extract :game, :at => "date"
        @game.extract :game, :at => "type", :as => :content
        @game.extract :game, :as => :title

        @klass.extract 'games/game', :class => @game
        parsed = @klass.parse(@data)
        parsed.game.should_not be_nil
        parsed.game.title.should == "Half-Life 2"
        parsed.game.content.should == "fullprice"
        parsed.game.steam_application_id.should == 220
        parsed.game.date.should == "2004-11-16"
      end

    end

  end

end

describe SMG::Model, ".extract" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = "<thing>just<another>yetanother</another>spec</thing>"
  end

  it "handles each element independently" do
    @klass.extract :thing
    parsed = @klass.parse(@data)
    parsed.thing.should == "justyetanotherspec"

    @klass.extract "thing/another"
    parsed = @klass.parse(@data)
    parsed.thing.should == "justyetanotherspec" # NOT "justspec"
    parsed.another.should == "yetanother"
  end

end
# EOF