require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/malus.xml')
  end

  describe "#extract with context" do

    before :each do
      @data = File.read(FIXTURES_DIR + 'fake/malus.xml')
    end

    it "ignores contextual elements when :context is not provided" do

      @klass.root 'spec'
      @klass.extract :genus
      @klass.extract :binomial
      @klass.extract :conservation  , :context => [:conservation]

      malus = @klass.parse(@data)
      malus.genus.should        == "Malus"
      malus.binomial.should     == "Malus sieversii (Ledeb.) M.Roem."
      malus.conservation.should be_nil

      malus = @klass.parse(@data, :conservation)
      malus.genus.should        == "Malus"
      malus.binomial.should     == "Malus sieversii (Ledeb.) M.Roem."
      malus.conservation.should == "Vulnerable (IUCN 2.3)"

    end

    it "allows for context of characters" do

      @klass.root 'spec'
      @klass.extract :genus         , :context => [:classification]
      @klass.extract :binomial      , :context => [:conservation, :classification]
      @klass.extract :conservation  , :context => [:conservation], :as => :status

      malus = @klass.parse(@data,:conservation)
      malus.genus.should    be_nil
      malus.binomial.should == "Malus sieversii (Ledeb.) M.Roem."
      malus.status.should   == "Vulnerable (IUCN 2.3)"

      malus = @klass.parse(@data,:classification)
      malus.genus.should    == "Malus"
      malus.binomial.should == "Malus sieversii (Ledeb.) M.Roem."
      malus.status.should   be_nil

    end

    it "allows for context of attributes" do
      @klass.root 'spec'
      @klass.extract :conservation  , :context => [:conservation], :at => :code

      malus = @klass.parse(@data,:conservation)
      malus.code.should == "VU"
      malus = @klass.parse(@data,:classification)
      malus.code.should be_nil
    end

    it "allows for context of nested resources" do
      cclass = Class.new { include SMG::Resource }
      cclass.extract :conservation  , :at => :code
      cclass.extract :conservation  , :as => :status

      @klass.root 'spec'
      @klass.extract :conservation  , :context => [:conservation], :class => cclass

      malus = @klass.parse(@data,:classification)
      malus.conservation.should be_nil

      malus = @klass.parse(@data,:conservation)
      malus.conservation.should be_an_instance_of cclass
      malus.conservation.status.should == "Vulnerable (IUCN 2.3)"
      malus.conservation.code.should == "VU"
    end

    it "maintains context inside nested resources" do
      cclass = Class.new { include SMG::Resource }
      cclass.extract :conservation  , :at => :code    , :context => [:conservation]
      cclass.extract :conservation  , :as => :status  , :context => [:conservation, :info]

      @klass.root 'spec'
      @klass.extract :conservation  , :class => cclass

      malus = @klass.parse(@data,:conservation)
      malus.conservation.should be_an_instance_of cclass
      malus.conservation.status.should == "Vulnerable (IUCN 2.3)"
      malus.conservation.code.should == "VU"

      malus = @klass.parse(@data,:info)
      malus.conservation.should be_an_instance_of cclass
      malus.conservation.status.should == "Vulnerable (IUCN 2.3)"
      malus.conservation.code.should be_nil
    end

  end

  describe "#collect with context" do

    before :each do
      @data = File.read(FIXTURES_DIR + 'discogs/Ophidian.xml')
    end

    it "ignores contextual collections when :context is not provided" do
      @klass.root 'resp/artist'
      @klass.collect 'namevariations/name'  , :as => :namevariations
      @klass.collect 'aliases/name'         , :as => :aliases,  :context => [:aliases]

      ophidian = @klass.parse(@data)
      ophidian.namevariations.should == ["Ohidian", "Ophidian as Raziel", "Ophidian [C. Hoyer]", "Ophidiom"]
      ophidian.aliases.should be_an ::Array
      ophidian.aliases.should be_empty

      ophidian = @klass.parse(@data, :aliases)
      ophidian.namevariations.should == ["Ohidian", "Ophidian as Raziel", "Ophidian [C. Hoyer]", "Ophidiom"]
      ophidian.aliases.should == ["Conrad Hoyer", "Cubist Boy", "Meander", "Trypticon"]
    end

    it "allows for context of collections" do
      @klass.root 'resp/artist'
      @klass.collect 'namevariations/name'  , :context => [:namevariations] , :as => :namevariations
      @klass.collect 'aliases/name'         , :context => [:aliases]        , :as => :aliases

      ophidian = @klass.parse(@data,:namevariations)
      ophidian.namevariations.should == ["Ohidian", "Ophidian as Raziel", "Ophidian [C. Hoyer]", "Ophidiom"]
      ophidian.aliases.should be_an ::Array
      ophidian.aliases.should be_empty

      ophidian = @klass.parse(@data,:aliases)
      ophidian.namevariations.should be_an ::Array
      ophidian.namevariations.should be_empty
      ophidian.aliases.should == ["Conrad Hoyer", "Cubist Boy", "Meander", "Trypticon"]
    end

    it "maintains context inside nested collections" do
      imgclass = Class.new { include SMG::Resource }
      imgclass.extract :image , :at => :uri150  , :as => :preview
      imgclass.extract :image , :at => :uri     , :as => :fullsize  , :context => [:everything]
      imgclass.extract :image , :at => :height  ,                     :context => [:everything]
      imgclass.extract :image , :at => :width   ,                     :context => [:everything]

      @klass.root 'resp/artist'
      @klass.collect 'images/image', :as => :images, :class => imgclass

      ophidian = @klass.parse(@data)
      ophidian.images.should be_an ::Array
      ophidian.images.size.should == 5

      image = ophidian.images[2]
      image.should be_an_instance_of imgclass
      image.height.should   be_nil
      image.width.should    be_nil
      image.fullsize.should be_nil
      image.preview.should  == "http://www.discogs.com/image/A-150-15203-1172410732.jpeg"

      ophidian = @klass.parse(@data, :everything)
      ophidian.images.should be_an ::Array
      ophidian.images.size.should == 5

      image = ophidian.images[2]
      image.should be_an_instance_of imgclass
      image.height.should   == "399"
      image.width.should    == "598"
      image.fullsize.should == "http://www.discogs.com/image/A-15203-1172410732.jpeg"
      image.preview.should  == "http://www.discogs.com/image/A-150-15203-1172410732.jpeg"
    end

  end

end

# EOF