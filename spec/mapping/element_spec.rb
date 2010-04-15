require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SMG::Mapping::Element do

  describe "instantiation" do

    describe "name and accessor" do

      it "respects path" do
        e = SMG::Mapping::Element.new(['node','subnode'])
        e.name.should == 'subnode'
        e.accessor.should == 'subnode='

        e = SMG::Mapping::Element.new(['node','subnode'], :nested => true)
        e.name.should == 'subnode'
        e.accessor.should == 'subnode='
      end

      it "respects :at option" do
        e = SMG::Mapping::Element.new(['node','subnode'], :at => :something)
        e.name.should == 'something'
        e.accessor.should == 'something='

        e = SMG::Mapping::Element.new(['node','subnode'], :at => :something, :nested => true)
        e.name.should == 'something'
        e.accessor.should == 'something='
      end

      it "respects :as option" do
        e = SMG::Mapping::Element.new(['node','subnode'], :at => :whatever, :as => :something)
        e.name.should == 'something'
        e.accessor.should == 'something='

        e = SMG::Mapping::Element.new(['node','subnode'], :as => :whatever, :nested => true)
        e.name.should == 'whatever'
        e.accessor.should == 'whatever='
      end

      it "respects :collection option" do
        e = SMG::Mapping::Element.new(['node','subnode'], :collection => true)
        e.name.should == 'subnode'
        e.accessor.should == 'attach_subnode'

        e = SMG::Mapping::Element.new(['node','subnode'], :at => :something, :collection => true)
        e.name.should == 'something'
        e.accessor.should == 'attach_something'

        e = SMG::Mapping::Element.new(['node','subnode'], :at => :whatever, :as => :something, :collection => true)
        e.name.should == 'something'
        e.accessor.should == 'attach_something'

        e = SMG::Mapping::Element.new(['node','subnode'], :as => :something, :collection => true)
        e.name.should == 'something'
        e.accessor.should == 'attach_something'
      end

    end

    it "knows if it is a collection" do
      e = SMG::Mapping::Element.new(['node','subnode'], :collection => true)
      e.should be_collection
    end

  end

end

# EOF