module DataMapper
  module Is
    module StateMachine
      module Data

        class Machine
          def initialize(definition, resource)
            @definition = definition
            @resource = resource
          end

          def run_initial
            return unless initial
            @resource.attribute_set(@definition.column, initial)
            return unless initial_state = @definition.find_state(initial)
            run_hook_if_present initial_state.options[:enter]
          end

          # hook may be either a Proc or symbol
          def run_hook_if_present(hook)
            return unless hook
            if hook.respond_to?(:call)
              hook.call(@resource)
            else
              @resource.__send__(hook)
            end
          end

          def initial
            @definition.initial
          end

          def find_event(event_name)
            @definition.find_event(event_name)
          end

          def fire_event(event_name)
            transition = @definition.fire_event(event_name, current_state_name)

            if via_state_name = transition[:via]
              self.current_state_name = via_state_name
            end

            # == Change the current_state ==
            self.current_state_name = transition[:to]
          end

          # Return the current state
          #
          # @api public
          def current_state
            @definition.find_state(current_state_name)
            # TODO: add caching, i.e. with `@current_state ||= ...`
          end

          def current_state_name
            @resource.attribute_get(@definition.column).to_s
          end

          def current_state_name=(state_name)
            # == Run :exit hook (if present) ==
            run_hook_if_present current_state.options[:exit]

            @resource.update(@definition.column => state_name.to_s)

            # == Run :enter hook (if present) ==
            run_hook_if_present current_state.options[:enter]
          end
        end

        # This Machine class represents one state machine.
        #
        # A model (i.e. a DataMapper resource) can have more than one Machine.
        class MachineDefinition

          # The property of the DM resource that will hold this Machine's
          # state.
          #
          # TODO: change :column to :property
          attr_accessor :column

          # The initial value of this Machine's state
          attr_accessor :initial

          attr_accessor :events

          attr_accessor :states

          def initialize(column, initial)
            @column, @initial   = column, initial
            @events, @states    = [], []
          end

          # Fire (activate) the event with name +event_name+
          #
          # @api public
          def fire_event(event_name, current_state_name)
            event_name = event_name.to_s
            unless event = find_event(event_name)
              raise InvalidEvent, "Could not find event (#{event_name.inspect})"
            end
            transition = event.transitions.find do |t|
               Array(t[:from]).any? do |from_state|
                 from_state.to_s == current_state_name
               end
            end
            unless transition
              raise InvalidEvent, "Event (#{event_name.inspect}) does not " +
              "exist for current state (#{current_state_name.inspect})"
            end
            transition
          end

          # Find event whose name is +event_name+
          #
          # @api semipublic
          def find_event(event_name)
            @events.find { |event| event.name.to_s == event_name.to_s }
            # TODO: use a data structure that prevents duplicates
          end

          # Find state whose name is +event_name+
          #
          # @api semipublic
          def find_state(state_name)
            @states.find { |state| state.name.to_s == state_name.to_s }
            # TODO: use a data structure that prevents duplicates
          end

        end

      end # Data
    end # StateMachine
  end # Is
end # DataMapper
