require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, ".extract and .collect with filtering" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/valve.xml')
  end

  it "works" do
    @klass.extract 'games/game', :with => {"date" => "To be announced"}, :as => :title
    game = @klass.parse(@data)
    game.title.should == "Half-Life 2: Episode Three"
  end

  it "works, really" do
    @klass.collect 'games/game', :with => {"type" => "episodic"}, :as => :episodic
    list = @klass.parse(@data)
    list.episodic.should == ["Half-Life 2: Episode One", "Half-Life 2: Episode Two", "Half-Life 2: Episode Three"]
  end

end