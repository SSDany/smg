require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, "#extract" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/valve.xml')
  end

  describe "using :with option" do

    it "extracts characters if element has suitable attributes" do
      @klass.extract 'games/game', :as => :title, :with => {:type => "episodic", :AppID => 420}
      game = @klass.parse(@data)
      game.title.should == "Half-Life 2: Episode Two"

      @klass.extract 'games/game', :as => :title, :with => {:type => "episodic", :date => "To be announced"}
      game = @klass.parse(@data)
      game.title.should == "Half-Life 2: Episode Three"

      @klass.extract 'games/game', :as => :title, :with => {:type => "episodic", :AppID => nil} # i.e. without @AppID attribute
      game = @klass.parse(@data)
      game.title.should == "Half-Life 2: Episode Three"
    end

    it "does nothing otherwise" do
      @klass.extract 'games/game', :as => :title, :with => {:type => "episodic", :AppID => "malformed"}
      game = @klass.parse(@data)
      game.title.should == nil
    end

  end

  describe "using :with and :at options together" do

    it "extracts attribute if element has suitable attributes" do
      conditions = {:type => "modification", :date => "2007-10-06"}
      @klass.extract 'games/game', :as => :steam_application_id, :with => conditions, :at => "AppID", :class => :integer
      game = @klass.parse(@data)
      game.steam_application_id.should == 380
    end

    it "does nothing otherwise" do
      conditions = {:type => "modification", :date => "fake"}
      @klass.extract 'games/game', :as => :steam_application_id, :with => conditions, :at => "AppID", :class => :integer
      game = @klass.parse(@data)
      game.steam_application_id.should == nil
    end

  end

  describe "using :with and :class options together" do

    before :each do
      @game = Class.new { include SMG::Resource }
      @game.extract :game, :at => "AppID", :as => :steam_application_id, :class => :integer
      @game.extract :game, :at => "date"
      @game.extract :game, :at => "type", :as => :content
      @game.extract :game, :as => :title
    end

    it "builds nested resource if element has suitable attributes" do
      conditions = {:type => "modification", :date => "2007-10-06"}
      @klass.extract 'games/game', :class => @game, :with => conditions
      parsed = @klass.parse(@data)
      parsed.game.should_not be_nil
      parsed.game.title.should == "Minerva: Metastasis"
      parsed.game.content.should == "modification"
      parsed.game.steam_application_id.should == 380
      parsed.game.date.should == "2007-10-06"
    end

    it "does nothing otherwise" do
      conditions = {:type => "modification", :date => "malformed"}
      @klass.extract 'games/game', :class => @game, :with => conditions
      parsed = @klass.parse(@data)
      parsed.game.should be_nil
    end

  end

end

describe SMG::Model, "#collect" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/valve.xml')
  end

  describe "using :with option" do

    it "collects characters of suitable elements" do
      @klass.collect 'games/game', :with => {"type" => "episodic"}, :as => :titles
      parsed = @klass.parse(@data)
      parsed.titles.should == ["Half-Life 2: Episode One", "Half-Life 2: Episode Two", "Half-Life 2: Episode Three"]
    end

    it "does nothing otherwise" do
      @klass.collect 'games/game', :with => {"type" => "unknowb"}, :as => :titles
      parsed = @klass.parse(@data)
      parsed.titles.should be_empty
    end

  end

  describe "using :with and :at options together" do

    it "collects attributes of suitable elements" do
      @klass.collect 'games/game', :with => {"type" => "episodic"}, :at => :date, :as => :dates
      parsed = @klass.parse(@data)
      parsed.dates.should == ["2006-06-01", "2007-10-10", "To be announced"]
    end

    it "does nothing otherwise" do
      @klass.collect 'games/game', :with => {"type" => "unknown"}, :at => :date, :as => :dates
      parsed = @klass.parse(@data)
      parsed.dates.should be_empty
    end

  end

  describe "using :with and :class options together" do

    before :each do
      @game = Class.new { include SMG::Resource }
      @game.extract :game, :at => "AppID", :as => :steam_application_id, :class => :integer
      @game.extract :game, :at => "date"
      @game.extract :game, :as => :title
    end

    it "builds collection from suitable elements" do
      conditions = {:type => "modification"}
      @klass.collect 'games/game', :class => @game, :with => conditions, :as => :games
      collection = @klass.parse(@data)

      collection.games.should_not be_empty
      collection.games.size.should == 2

      collection.games[0].title.should == "Minerva: Metastasis"
      collection.games[0].steam_application_id.should == 380
      collection.games[0].date.should == "2007-10-06"

      collection.games[1].title.should == "Black Mesa"
      collection.games[1].steam_application_id.should == nil
      collection.games[1].date.should == "To be announced"
    end

    it "does nothing otherwise" do
      conditions = {:type => "unknown"}
      @klass.collect 'games/game', :class => @game, :with => conditions, :as => :games
      collection = @klass.parse(@data)
      collection.games.should be_empty
    end

  end

end

# EOF