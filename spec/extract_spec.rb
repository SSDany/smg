require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, ".extract" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = File.read(FIXTURES_DIR + 'fake/malus.xml')
  end

  describe "extract" do

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

    it "extracts an empty string if there's an empty element" do
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

      it "extracts data from an element into the 'as' accessor" do
        @klass.extract 'spec/conservation', :as => :conservation_status
        malus = @klass.parse(@data)
        malus.conservation_status.should == 'Vulnerable (IUCN 2.3)'
      end

      it "extracts nothing if there'no appropriate element" do
        @klass.extract 'spec/bogus', :as => :conservation_code, :at => :bogus
        malus = @klass.parse(@data)
        malus.conservation_code.should == nil
      end

    end

    describe "whith :class option" do

      describe "when :class options represents SMG::Resource" do

        it "extracts data into the class (AKA has_one)" do
          @foo = Class.new
          @foo.send(:include, SMG::Resource)
          @foo.root :description
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

      describe "when :class options represents build-in typecast" do

        it "typecasts" do
          pending "write me, please"
        end

      end

    end

  end

end

# EOF