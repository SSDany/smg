require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SMG::Mapping::Element do

  describe "#initialize" do

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
      e = SMG::Mapping::Element.new(['node','subnodes'], :collection => true)
      e.name.should == :subnodes
      e.accessor.should == :append_to_subnodes

      e = SMG::Mapping::Element.new(['node','subnodes'], :at => :something, :collection => true)
      e.name.should == :something
      e.accessor.should == :append_to_something

      e = SMG::Mapping::Element.new(['node','subnodes'], :at => :whatever, :as => :something, :collection => true)
      e.name.should == :something
      e.accessor.should == :append_to_something

      e = SMG::Mapping::Element.new(['node','subnodes'], :as => :something, :collection => true)
      e.name.should == :something
      e.accessor.should == :append_to_something
    end

    it "defaults @context to nil" do
      e = SMG::Mapping::Element.new(['node','subnode'])
      e.context.should be_nil
    end

    describe "with :class option" do

      it "defines the @data_class if :class is an SMG::Model" do
        klass = Class.new { include SMG::Resource }
        e = SMG::Mapping::Element.new(['node'], :class => klass)
        e.data_class.should == klass
      end

      it "defines the @cast_to if :class is a valid typecast" do
        klass = Class.new { include SMG::Resource }
        e = SMG::Mapping::Element.new(['node'], :class => :string)
        e.cast_to.should == :string
      end

      it "raises an ArgumentError otherwise" do
        lambda { SMG::Mapping::Element.new(['node'], :class => "bogus!")}.
        should raise_error ArgumentError, %r{should be an SMG::Model or a valid typecast}
      end

    end

    describe "with :context option" do

      it "defaults @context to nil, if :context is an empty Array" do
        e = SMG::Mapping::Element.new(['node'], :context => [])
        e.context.should be_nil
      end

      it "removes nils and duplicates from @context" do

        e = SMG::Mapping::Element.new(['node'], :context => [:foo, nil, :bar, :baz])
        e.context.should == [:foo, :bar, :baz]

        e = SMG::Mapping::Element.new(['node'], :context => [:foo, :bar, nil, :foo, :baz])
        e.context.should == [:foo, :bar, :baz]

        e = SMG::Mapping::Element.new(['node'], :context => [nil])
        e.context.should be_nil

        # undestructive
        cct = [:foo, :foo, :bar]
        e = SMG::Mapping::Element.new(['node','subnode'], :context => cct)
        cct.should == [:foo, :foo, :bar]

      end

      it "raises an ArgumentError, if :context is not an Array" do
        lambda { e = SMG::Mapping::Element.new(['node'], :context => "something") }.
        should raise_error ArgumentError, %r{should be an Array}
      end

    end

  end

  describe "#collection?" do

    it "returns true if Element is a collection" do
      e = SMG::Mapping::Element.new(['node','subnode'], :collection => true)
      e.should be_a_collection
    end

    it "returns false otherwise" do
      e = SMG::Mapping::Element.new(['node','subnode'])
      e.should_not be_a_collection
    end

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

  describe "#in_context_of?" do

    it "returns true if @context of an Element is a nil" do
      e = SMG::Mapping::Element.new(['node','subnode'])
      e.context.should == nil
      e.in_context_of?(:whatever).should == true
    end

    it "returns true if @context of an Element includes context" do
      e = SMG::Mapping::Element.new(['node','subnode'], :context => [:foo])
      e.context.should == [:foo]
      e.in_context_of?(:foo).should == true
    end

    it "returns false otherwise" do
      e = SMG::Mapping::Element.new(['node','subnode'], :context => [:foo])
      e.context.should == [:foo]
      e.in_context_of?(:bar).should == false
    end

  end

  describe "#with?" do

    it "returns true if the hash passed contains @with" do
      e = SMG::Mapping::Element.new(['node'], :with => {"id" => "3", "status" => "accepted"})
      e.should be_with("id" => "3", "status" => "accepted")
      e.should be_with("id" => "3", "status" => "accepted", "key" => "value")
    end

    it "returns true if there are no @with conditions" do
      e = SMG::Mapping::Element.new(['node','subnode'])
      e.with.should == nil
      e.should be_with("key" => "value")
    end

    it "returns false otherwise" do
      e = SMG::Mapping::Element.new(['node'], :with => {"id" => "3", "status" => "accepted"})
      e.should_not be_with("status" => "accepted")
      e.should_not be_with({})
    end

  end

end

# EOF