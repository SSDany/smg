require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Resource, "typecasting" do

  it "works" do
    klass = Class.new { include SMG::Resource }
    klass.extract :answer, :class => :integer
    question = klass.parse('<?xml version="1.0" encoding="UTF-8"?><answer>42</answer>')
    question.answer.should == 42
  end

end

#EOF