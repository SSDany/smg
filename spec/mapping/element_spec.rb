require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SMG::Mapping::Element do

  describe "instantiation" do

    describe "name and accessor" do

      it "respects path" do
        e = SMG::Mapping::Element.new(['node','subnode'])
        e.name.should == :subnode
        e.accessor.should == :subnode=

        e = SMG::Mapping::Element.new(['node','subnode'], :nested => true)
        e.name.should == :subnode
        e.accessor.should == :subnode=
      end

      it "respects :at option" do
        e = SMG::Mapping::Element.new(['node','subnode'], :at => :something)
        e.name.should == :something
        e.accessor.should == :something=

        e = SMG::Mapping::Element.new(['node','subnode'], :at => :something, :nested => true)
        e.name.should == :something
        e.accessor.should == :something=
      end

      it "respects :as option" do
        e = SMG::Mapping::Element.new(['node','subnode'], :at => :whatever, :as => :something)
        e.name.should == :something
        e.accessor.should == :something=

        e = SMG::Mapping::Element.new(['node','subnode'], :as => :whatever, :nested => true)
        e.name.should == :whatever
        e.accessor.should == :whatever=
      end

      it "respects :collection option" do
        e = SMG::Mapping::Element.new(['node','subnode'], :collection => true)
        e.name.should == :subnode
        e.accessor.should == :attach_subnode

        e = SMG::Mapping::Element.new(['node','subnode'], :at => :something, :collection => true)
        e.name.should == :something
        e.accessor.should == :attach_something

        e = SMG::Mapping::Element.new(['node','subnode'], :at => :whatever, :as => :something, :collection => true)
        e.name.should == :something
        e.accessor.should == :attach_something

        e = SMG::Mapping::Element.new(['node','subnode'], :as => :something, :collection => true)
        e.name.should == :something
        e.accessor.should == :attach_something
      end

    end

    describe "with :class option" do

      describe "and :class is a Class" do

        it "raises an ArgumentError if :class is a Class, but not an SMG::Model" do
          klass = Class.new
          lambda { SMG::Mapping::Element.new(['node'], :class => klass)}.
          should raise_error ArgumentError, %r{is not an SMG::Model}
        end

        it "defines @data_class otherwise" do
          klass = Class.new { include SMG::Resource }
          e = SMG::Mapping::Element.new(['node'], :class => klass)
          e.data_class.should == klass
        end

      end

      describe "and :class is a Symbol" do

        it "raises an ArgumentError if :class is a Symbol, but not a valid typecast" do
          lambda { SMG::Mapping::Element.new(['node'], :class => :bogus)}.
          should raise_error ArgumentError, %r{is not a valid typecast}
        end

        it "defines @cast_to otherwise" do
          klass = Class.new { include SMG::Resource }
          e = SMG::Mapping::Element.new(['node'], :class => :string)
          e.cast_to.should == :string
        end

      end

      describe "and :class is a not a Class or Symbol" do
        it "raises an ArgumentError" do
          lambda { SMG::Mapping::Element.new(['node'], :class => "bogus!")}.
          should raise_error ArgumentError, %r{should be an SMG::Model or a Symbol}
        end
      end

    end

  end

  it "knows if it is a collection" do
    e = SMG::Mapping::Element.new(['node','subnode'], :collection => true)
    e.should be_collection
  end

  describe "#cast" do

    it "returns the same value if there's no @cast_to" do
      e = SMG::Mapping::Element.new(['node'])
      thing = "42"
      e.cast(thing).should be_eql thing
    end

    it "performs the typecast otherwise" do
      e = SMG::Mapping::Element.new(['node'], :class => :integer)
      thing = "42"
      SMG::Mapping::TypeCasts.should_receive(:[]).with(:integer, thing).and_return("42 (typecasted)")
      e.cast(thing).should == "42 (typecasted)"
    end

    it "raises an ArgumentError if typecasting fails" do
      e = SMG::Mapping::Element.new(['node'], :class => :datetime)
      lambda { e.cast('42') }.
      should raise_error ArgumentError, %r{"42" is not a valid source for :datetime}
    end

  end

end

# EOF