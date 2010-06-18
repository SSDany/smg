require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SMG::Mapping::TypeCasts, "[]" do

  it "raises an ArgumentError when typecast is unknown" do
    lambda { SMG::Mapping::TypeCasts[:bogus, "42"] }.should raise_error ArgumentError, %r{Can't typecast String into :bogus}
  end

  it "type casts into String" do
    SMG::Mapping::TypeCasts[ :string  , 42    ].should == "42"
    SMG::Mapping::TypeCasts[ :string  , nil   ].should == ""
  end

  it "type casts into Fixnum" do
    SMG::Mapping::TypeCasts[ :integer , "42"  ].should == 42
    SMG::Mapping::TypeCasts[ :integer , nil   ].should == 0
  end

  it "type casts into Float" do
    SMG::Mapping::TypeCasts[ :float   , nil   ].should == 0.00
    SMG::Mapping::TypeCasts[ :float   , ".42" ].should == 0.42
    SMG::Mapping::TypeCasts[ :float   , "42"  ].should == 42.00
    SMG::Mapping::TypeCasts[ :float   , "42." ].should == 42.00
  end

  it "type casts into Symbol" do
    SMG::Mapping::TypeCasts[ :symbol  , "something" ].should == :something
  end

  it "type casts Stringable into Boolean" do
    SMG::Mapping::TypeCasts[ :boolean , nil         ].should == nil
    SMG::Mapping::TypeCasts[ :boolean , "true"      ].should == true
    SMG::Mapping::TypeCasts[ :boolean , "something" ].should == true
    SMG::Mapping::TypeCasts[ :boolean , "false"     ].should == false
  end

  it "type casts into Time" do
    source = 'Thu Apr 15 18:16:23 +0400 2010'
    value = SMG::Mapping::TypeCasts[:datetime, source]
    value.should == Time.parse(source)
  end

  it "type casts into Date" do
    source = 'Thu Apr 15 18:16:23 +0400 2010'
    value = SMG::Mapping::TypeCasts[:date, source]
    value.should == Date.parse(source)
  end

  it "type casts Stringable into URI" do
    source = "http://example.org:4567/foo?bar=baz"
    value = SMG::Mapping::TypeCasts[:uri, source]
    value.should == URI.parse(source)
  end

end

# EOF