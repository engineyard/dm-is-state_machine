require 'spec_helper'
require 'examples/light_switch'

describe 'Inherited state machine' do

  it 'should not explode' do
    dimmer = Dimmer.new
    lambda { dimmer.transition!(:switch) }.should_not raise_error(NoMethodError)
  end

end
