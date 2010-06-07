require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, ".extract" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/valve.xml')
  end

  describe "using :with option" do

    it "extracts content of the element if conditions are OK" do
      @klass.extract 'games/game', :as => :title, :with => {:type => "episodic", :AppID => "420"}
      game = @klass.parse(@data)
      game.title.should == "Half-Life 2: Episode Two"

      @klass.extract 'games/game', :as => :title, :with => {:type => "episodic", :date => "To be announced"}
      game = @klass.parse(@data)
      game.title.should == "Half-Life 2: Episode Three"
    end

    it "extracts nothing otherwise" do
      @klass.extract 'games/game', :as => :title, :with => {:type => "episodic", :AppID => "malformed"}
      game = @klass.parse(@data)
      game.title.should == nil
    end

  end

  describe "using :with and :at options alltogether" do

    it "extracts content of the element if conditions are OK" do
      conditions = {:type => "modification", :date => "2007-10-06"}
      @klass.extract 'games/game', :as => :steam_application_id, :with => conditions, :at => "AppID", :class => :integer
      @klass.extract 'games/game', :as => :title, :with => conditions
      game = @klass.parse(@data)
      game.steam_application_id.should == 380
      game.title.should == "Minerva: Metastasis"
    end

    it "extracts nothing otherwise" do
      conditions = {:type => "modification", :date => "fake"}
      @klass.extract 'games/game', :as => :steam_application_id, :with => conditions, :at => "AppID", :class => :integer
      @klass.extract 'games/game', :as => :title, :with => conditions
      game = @klass.parse(@data)
      game.steam_application_id.should == nil
      game.title.should == nil
    end

  end

  describe "using :with and :class options alltogether" do

    before :each do
      @game = Class.new { include SMG::Resource }
      @game.extract :game, :at => "AppID", :as => :steam_application_id, :class => :integer
      @game.extract :game, :at => "date"
      @game.extract :game, :at => "type", :as => :content
      @game.extract :game, :as => :title
    end

    it "extracts content of the element if conditions are OK" do
      conditions = {:type => "modification", :date => "2007-10-06"}
      @klass.extract 'games/game', :class => @game, :with => conditions
      parsed = @klass.parse(@data)
      parsed.game.should_not be_nil
      parsed.game.title.should == "Minerva: Metastasis"
      parsed.game.content.should == "modification"
      parsed.game.steam_application_id.should == 380
      parsed.game.date.should == "2007-10-06"
    end

    it "extracts nothing otherwise" do
      conditions = {:type => "modification", :date => "malformed"}
      @klass.extract 'games/game', :class => @game, :with => conditions
      parsed = @klass.parse(@data)
      parsed.game.should be_nil
    end

  end

end

describe SMG::Model, ".collect" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/valve.xml')
  end

  describe "using :with option" do

    it "is able to collect attributes, if conditions are OK" do
      @klass.collect 'games/game', :with => {"type" => "episodic"}, :at => :date, :as => :dates
      parsed = @klass.parse(@data)
      parsed.dates.should == ["2006-06-01", "2007-10-10", "To be announced"]
    end

    it "is able to collect texts, if conditions are OK" do
      @klass.collect 'games/game', :with => {"type" => "episodic"}, :as => :titles
      parsed = @klass.parse(@data)
      parsed.titles.should == ["Half-Life 2: Episode One", "Half-Life 2: Episode Two", "Half-Life 2: Episode Three"]
    end

  end

end