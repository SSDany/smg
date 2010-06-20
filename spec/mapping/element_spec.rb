require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SMG::Mapping::Element do

  def e(*args)
    SMG::Mapping::Element.new(*args)
  end

  describe "#name" do

    it "uses :as option as a name when provided" do
      e(['node','subnode'     ], :as => :whatever).name.should == :whatever
      e(['node','ns:subnode'  ], :as => :whatever).name.should == :whatever
      e(['node','subnode'     ], :as => :whatever, :at => :something).name.should == :whatever
      e(['node','ns:subnode'  ], :as => :whatever, :at => :something).name.should == :whatever
    end

    it "uses :at option as a name when :as option is not provided" do
      e(['node','subnode'     ], :at => :something).name.should == :something
      e(['node','ns:subnode'  ], :at => :something).name.should == :something
    end

    it "fallbacks to the path otherwise" do
      e(['node','subnode'     ]).name.should == :subnode
      e(['node','ns:subnode'  ]).name.should == :ns_subnode
    end

    it "ignores :collection option" do
      e(['node','subnodes'    ], :collection => true).name.should == :subnodes
      e(['node','ns:subnodes' ], :collection => true).name.should == :ns_subnodes
      e(['node','subnodes'    ], :collection => true, :as => :whatever, :at => :something).name.should == :whatever
      e(['node','ns:subnodes' ], :collection => true, :as => :whatever, :at => :something).name.should == :whatever
      e(['node','subnodes'    ], :collection => true, :as => :whatever).name.should == :whatever
      e(['node','ns:subnodes' ], :collection => true, :as => :whatever).name.should == :whatever
      e(['node','subnodes'    ], :collection => true, :at => :something).name.should == :something
      e(['node','ns:subnodes' ], :collection => true, :at => :something).name.should == :something
    end

  end

  describe "#accessor" do

    describe "when :collection options is not provided" do

      it "uses :as option as an accessor when provided" do
        e(['node','subnode'     ], :as => :whatever).accessor.should == :whatever=
        e(['node','ns:subnode'  ], :as => :whatever).accessor.should == :whatever=
        e(['node','subnode'     ], :as => :whatever, :at => :something).accessor.should == :whatever=
        e(['node','ns:subnode'  ], :as => :whatever, :at => :something).accessor.should == :whatever=
      end

      it "uses :at option as an accessor when :as option is not provided" do
        e(['node','subnode'     ], :at => :something).accessor.should == :something=
        e(['node','ns:subnode'  ], :at => :something).accessor.should == :something=
      end

      it "fallbacks to the path otherwise" do
        e(['node','subnode'     ]).accessor.should == :subnode=
        e(['node','ns:subnode'  ]).accessor.should == :ns_subnode=
      end

    end

    describe "when :collection option provided" do

      it "uses :as option as a part of an accessor when provided" do
        e(['node','subnode'     ], :collection => true, :as => :whatever).accessor.should == :append_to_whatever
        e(['node','ns:subnode'  ], :collection => true, :as => :whatever).accessor.should == :append_to_whatever
        e(['node','subnode'     ], :collection => true, :as => :whatever, :at => :something).accessor.should == :append_to_whatever
        e(['node','ns:subnode'  ], :collection => true, :as => :whatever, :at => :something).accessor.should == :append_to_whatever
      end

      it "uses :at option as a part of an accessor when :as option is not provided" do
        e(['node','subnode'     ], :collection => true, :at => :something).accessor.should == :append_to_something
        e(['node','ns:subnode'  ], :collection => true, :at => :something).accessor.should == :append_to_something
      end

      it "fallbacks to the path otherwise" do
        e(['node','subnode'     ], :collection => true).accessor.should == :append_to_subnode
        e(['node','ns:subnode'  ], :collection => true).accessor.should == :append_to_ns_subnode
      end

    end

  end

  describe "#initialize" do

    it "defaults @context to nil" do
      element = e(['node','subnode'])
      element.context.should be_nil
    end

    describe "when :class option provided" do

      describe "and :class is an SMG::Model" do

        it "sets data_class to :class" do
          klass = Class.new { include SMG::Resource }
          element = e(['node'], :class => klass)
          element.data_class.should == klass
        end

        it "ignores :at option when :collection option provided" do
          klass = Class.new { include SMG::Resource }
          element = e(['node'], :class => klass, :at => :whatever, :collection => true)
          element.at.should be_nil
        end

      end

      it "sets cast_to to :class if :class is a valid typecast" do
        element = e(['node'], :class => :string)
        element.cast_to.should == :string
      end

      it "raises an ArgumentError otherwise" do
        lambda { SMG::Mapping::Element.new(['node'], :class => "bogus!") }.
        should raise_error ArgumentError, %r{should be an SMG::Model or a valid typecast}
      end

    end

    describe "when :context option provided" do

      it "defaults context to nil if :context is an empty Array or a nil" do
        element = e(['node'], :context => [])
        element.context.should be_nil
        element = e(['node'], :context => nil)
        element.context.should be_nil
      end

      it "sets context otherwise" do
        element = e(['node'], :context => :custom)
        element.context.should == [:custom]
      end

      it "removes duplicates from @context" do
        cct = [:foo, :bar, :foo, :bar, :baz, :baz]
        element = e(['node'], :context => cct)
        element.context.should == [:foo, :bar, :baz]
        cct.should == [:foo, :bar, :foo, :bar, :baz, :baz] # undestructive
      end

    end

  end

  describe "#collection?" do

    it "returns true if self is a collection" do
      element = e(['node','subnode'], :collection => true)
      element.should be_a_collection
    end

    it "returns false otherwise" do
      element = e(['node','subnode'])
      element.should_not be_a_collection
      element = e(['node','subnode'], :collection => false)
      element.should_not be_a_collection
    end

  end

  describe "#cast" do

    it "does nothing if cast_to is a nil" do
      element = e(['node'])
      thing = "42"
      element.cast(thing).should be_eql thing
    end

    it "performs the typecast otherwise" do
      raw, typecasted = "raw", "typecasted"
      SMG::Mapping::TypeCasts.should_receive(:key?).with(:custom).and_return(true)
      SMG::Mapping::TypeCasts.should_receive(:[]).with(:custom,raw).and_return(typecasted)
      element = e(['node'], :class => :custom)
      element.cast(raw).should == typecasted
    end

    it "raises an ArgumentError if typecasting fails" do
      element = e(['node'], :class => :datetime)
      lambda { element.cast('42') }.
      should raise_error ArgumentError, %r{"42" is not a valid source for :datetime}
    end

  end

  describe "#in_context_of?" do

    it "returns true if context of self is a nil" do
      element = e(['node','subnode'])
      element.context.should == nil
      element.should be_in_context_of(:whatever)
    end

    it "returns true if context of self includes the value passed" do
      element = e(['node','subnode'], :context => [:whatever])
      element.context.should == [:whatever]
      element.should be_in_context_of(:whatever)
    end

    it "returns false otherwise" do
      element = e(['node','subnode'], :context => [:whatever])
      element.context.should == [:whatever]
      element.should_not be_in_context_of(:bogus)
    end

  end

  describe "#with?" do

    it "returns true if the Hash passed satisifies conditions" do
      element = e(['node'], :with => {"id" => "3", "status" => "accepted"})
      element.should be_with("id" => "3", "status" => "accepted")
      element.should be_with("id" => "3", "status" => "accepted", "key" => "value")
    end

    it "returns true if conditions does not set" do
      element = e(['node','subnode'])
      element.with.should == nil
      element.should be_with("key" => "value")
    end

    it "returns false otherwise" do
      element = e(['node'], :with => {"id" => "3", "status" => "accepted"})
      element.should_not be_with("status" => "accepted")
      element.should_not be_with({})
    end

  end

end

# EOF