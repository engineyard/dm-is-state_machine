require 'spec_helper'

module MachineHelper
  def new_definition(*args)
    DataMapper::Is::StateMachine::Data::MachineDefinition.new(*args)
  end

  def new_state(name, machine, options = {})
    mock(name, :name => name, :machine => machine, :options => options)
  end

  def new_event(name, machine)
    mock(name, :name => name, :machine => machine)
  end
end

describe DataMapper::Is::StateMachine::Data::MachineDefinition do
  include MachineHelper

  describe "new MachineDefinition, no events" do
    before(:each) do
      @definition = new_definition(:power, :off)
    end

    it "#column should work" do
      @definition.column.should == :power
    end

    it "#initial should work" do
      @definition.initial.should == :off
    end

    it "#events should work" do
      @definition.events.should == []
    end

    it "#states should work" do
      @definition.states.should == []
    end

    it "#find_event should return nothing" do
      @definition.find_event(:turn_on).should == nil
    end

    it "#fire_event should raise error" do
      lambda {
        @definition.fire_event(:turn_on, nil)
      }.should raise_error(DataMapper::Is::StateMachine::InvalidEvent)
    end
  end

  describe "new Machine, 2 states, 1 event" do
    before(:each) do
      @definition = new_definition(:power, :off)
      @definition.states << (@off_state = new_state(:off, @definition))
      @definition.states << (@on_state = new_state(:on, @definition))
      @definition.events << (@turn_on = new_event(:turn_on, @definition))
      @turn_on.stub!(:transitions).and_return([{ :from => :off, :to => :on }])
    end

    it "#column should work" do
      @definition.column.should == :power
    end

    it "#initial should work" do
      @definition.initial.should == :off
    end

    it "#events should work" do
      @definition.events.should == [@turn_on]
    end

    it "#states should work" do
      @definition.states.should == [@off_state, @on_state]
    end

    #it "#current_state should work" do
      #@definition.current_state.should == @off_state
    #end

    #it "#current_state_name should work" do
      #@definition.current_state_name.should == :off
    #end

    it "#find_event should return nothing" do
      @definition.find_event(:turn_on).should == @turn_on
    end

    #it "#fire_event should change state" do
      #resource = mock("resource")
      #resource.should_receive(:run_hook_if_present).exactly(2).times.with(nil)
      #@definition.fire_event(:turn_on, resource)
      #@definition.current_state.should == @on_state
      #@definition.current_state_name.should == :on
    #end

  end

  # TODO: spec fire_event where :run_hook_if_present fires two times,
  # but with :enter the first and :exit the second.

end
