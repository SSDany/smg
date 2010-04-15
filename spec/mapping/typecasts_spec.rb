require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SMG::Mapping::TypeCasts, "[]" do

  it "raises an ArgumentError when typecast is unknown" do
    lambda { SMG::Mapping::TypeCasts[:bogus, "42"] }.should raise_error ArgumentError, %r{Can't typecast to :bogus}
  end

  it "is able to typecast (Stringable) into Fixnum" do
    SMG::Mapping::TypeCasts[:integer, "42"].should == 42
  end

  it "is able to typecast (Stringable) into Symbol" do
    SMG::Mapping::TypeCasts[:symbol, "something"].should == :something
  end

  it "is able to typecast (Stringable) into Time" do
    value = SMG::Mapping::TypeCasts[:datetime,'Thu Apr 15 18:16:23 +0400 2010']
    value.should == Time.parse('Thu Apr 15 18:16:23 +0400 2010')
  end

  it "is able to typecast (Stringable) into Date" do
    value = SMG::Mapping::TypeCasts[:date,'Thu Apr 15 18:16:23 +0400 2010']
    value.should == Date.parse('Thu Apr 15 18:16:23 +0400 2010')
  end

  it "is able to typecast (Stringable) into URI" do
    value = SMG::Mapping::TypeCasts[:uri,"http://example.org:4567/foo?bar=baz"]
    value.should be_an_instance_of URI::HTTP
    value.scheme.should == 'http'
    value.host.should == 'example.org'
    value.port.should == 4567
    value.path.should == '/foo'
    value.query.should == 'bar=baz'
  end

  it "is able to typecast (Stringable) into Boolean" do
    SMG::Mapping::TypeCasts[  :boolean  , "true"      ].should == true
    SMG::Mapping::TypeCasts[  :boolean  , "something" ].should == true
    SMG::Mapping::TypeCasts[  :boolean  , nil         ].should == true
    SMG::Mapping::TypeCasts[  :boolean  , "false"     ].should == false
  end

end

# EOF