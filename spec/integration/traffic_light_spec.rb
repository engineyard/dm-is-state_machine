require 'spec_helper'
require 'examples/traffic_light'

describe TrafficLight do

  before(:each) do
    @t = TrafficLight.create
  end

  it "should have a 'color' column" do
    @t.attributes.should have_key(:color)
  end

  it "should not have a 'state' column" do
    @t.attributes.should_not have_key(:state)
  end

  it "should start off in the green state" do
    @t.color.should == "green"
  end

  it "should allow the color to be set" do
    @t.color = :yellow
    @t.save
    @t.color.should == "yellow"
  end

  it "should have called the :enter Proc" do
    @t.log.should == %w(G)
  end

  it "should call the original initialize method" do
    @t.init.should == [:init]
  end

  describe 'forward!' do

    it "should transition to :yellow, :red, :green" do
      @t.color.should == "green"
      @t.transition!(:forward)
      @t.color.should == "yellow"
      @t.log.should == %w(G Y)
      @t.transition!(:forward)
      @t.color.should == "red"
      @t.log.should == %w(G Y R)
      @t.transition!(:forward)
      @t.color.should == "green"
      @t.log.should == %w(G Y R G)
    end

    it "should skip to :yellow then transition to :red, :green, :yellow" do
      @t.color = :yellow
      @t.save
      @t.color.should == "yellow"
      @t.log.should == %w(G)
      @t.transition!(:forward)
      @t.color.should == "red"
      @t.log.should == %w(G R)
      @t.transition!(:forward)
      @t.color.should == "green"
      @t.log.should == %w(G R G)
      @t.transition!(:forward)
      @t.color.should == "yellow"
      @t.log.should == %w(G R G Y)
    end

    it "should skip to :red then transition to :green, :yellow, :red" do
      @t.color = :red
      @t.save
      @t.color.should == "red"
      @t.log.should == %w(G)
      @t.transition!(:forward)
      @t.color.should == "green"
      @t.log.should == %w(G G)
      @t.transition!(:forward)
      @t.color.should == "yellow"
      @t.log.should == %w(G G Y)
      @t.transition!(:forward)
      @t.color.should == "red"
      @t.log.should == %w(G G Y R)
    end

  end

  describe 'backward!' do

    it "should transition to :red, :yellow, :green" do
      @t.color.should == "green"
      @t.log.should == %w(G)
      @t.transition!(:backward)
      @t.color.should == "red"
      @t.log.should == %w(G R)
      @t.transition!(:backward)
      @t.color.should == "yellow"
      @t.log.should == %w(G R Y)
      @t.transition!(:backward)
      @t.color.should == "green"
      @t.log.should == %w(G R Y G)
    end

    it "should skip to :yellow then transition to :green, :red, :yellow" do
      @t.color = :yellow
      @t.save
      @t.color.should == "yellow"
      @t.log.should == %w(G)
      @t.transition!(:backward)
      @t.color.should == "green"
      @t.log.should == %w(G G)
      @t.transition!(:backward)
      @t.color.should == "red"
      @t.log.should == %w(G G R)
      @t.transition!(:backward)
      @t.color.should == "yellow"
      @t.log.should == %w(G G R Y)
    end

    it "should skip to :red then transition to :yellow, :green, :red" do
      @t.color = :red
      @t.save
      @t.color.should == "red"
      @t.log.should == %w(G)
      @t.transition!(:backward)
      @t.color.should == "yellow"
      @t.log.should == %w(G Y)
      @t.transition!(:backward)
      @t.color.should == "green"
      @t.log.should == %w(G Y G)
      @t.transition!(:backward)
      @t.color.should == "red"
      @t.log.should == %w(G Y G R)
    end

  end

  describe "hooks" do

    it "should log initial state before state is changed on a before hook" do
      @t.transition!(:forward)
      @t.before_hook_log.should == %w(green)
      @t.transition!(:forward)
      @t.before_hook_log.should == %w(green yellow)
      @t.transition!(:forward)
      @t.before_hook_log.should == %w(green yellow red)
    end

    it "should log final state before state is changed on a before hook" do
      @t.transition!(:forward)
      @t.after_hook_log.should == %w(yellow)
      @t.transition!(:forward)
      @t.after_hook_log.should == %w(yellow red)
      @t.transition!(:forward)
      @t.after_hook_log.should == %w(yellow red green)
    end

  end

  describe "overwriting event methods" do

    before(:all) do
      TrafficLight.class_eval "def transition!(name, added_param); if name == :forward; log << added_param; end; state_machine.fire_event(name); end"
    end

    it "should transition normally with added functionality" do
      @t.color.should == "green"
      @t.transition!(:forward, "test")
      @t.color.should == "yellow"
      @t.log.should == %w(G test Y)
    end

  end
end
