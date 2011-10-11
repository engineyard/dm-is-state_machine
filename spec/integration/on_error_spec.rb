require 'spec_helper'
require 'examples/on_error'

describe OnError do

  before(:each) do
    @e = OnError.create
  end

  it "should start off in the red state" do
    @e.state.should == "red"
  end

  it "should enter the error state on errors" do
    lambda { @e.transition!(:go) }.should raise_exception
    @e.should be_state(:starting_failed)
  end

  it "should retry from an error state" do
    lambda { @e.transition!(:go) }.should raise_exception
    @e.should be_state(:starting_failed)

    @e.transition!(:retry)
    @e.should be_state(:green)
  end
end
