module DataMapper
  module Is
    module StateMachine
      module Data

        class Event

          attr_reader :name, :machine, :transitions

          def initialize(name, machine)
            @name        = name
            @machine     = machine
            @transitions = []
          end

          def add_transition(from, to, via, error)
            @transitions << { :from => from, :to => to, :via => via, :error => error}
          end

        end

      end # Data
    end # StateMachine
  end # Is
end # DataMapper
