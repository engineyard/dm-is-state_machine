module DataMapper
  module Is
    module StateMachine
      # Event DSL (Domain Specific Language)
      module EventDsl

        # Define an event. This takes a block which describes all valid
        # transitions for this event.
        #
        # Example:
        #
        #   class TrafficLight
        #     include DataMapper::Resource
        #     property :id, Serial
        #     is :state_machine, :initial => :green, :column => :color do
        #       # state definitions go here...
        #
        #       event :forward do
        #         transition :from => :green,  :to => :yellow
        #         transition :from => :yellow, :to => :red
        #         transition :from => :red,    :to => :green
        #       end
        #     end
        #   end
        #
        # +transition+ takes a hash where <tt>:to</tt> is the state to transition
        # to and <tt>:from</tt> is a state (or Array of states) from which this
        # event can be fired.
        def event(name, options = {}, &block)
          unless state_machine_context?(:is)
            raise InvalidContext, "Valid only in 'is :state_machine' block"
          end

          name = name.to_s

          options[:method] = true unless options.key?(:method)

          # ===== Setup context =====
          definition = @is_state_machine[:definition]
          event = Data::Event.new(name, definition)
          definition.events << event
          @is_state_machine[:event] = {
            :name   => name,
            :object => event
          }
          push_state_machine_context(:event)

          # ===== Define methods =====
          if options[:method]
            define_method("#{name}!") do
              puts "transitioning to #{name.inspect}"
              transition!(name)
            end
          end

          # Possible alternative to the above:
          # (class_eval is typically faster than define_method)
          #
          # self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #   def #{name}!
          #     machine.current_state_name = __send__(:"#{column}")
          #     machine.fire_event(name, self)
          #     __send__(:"#{column}="), machine.current_state_name
          #   end
          # RUBY

          yield if block_given?

          # ===== Teardown context =====
          pop_state_machine_context
        end

        def transition(options)
          unless state_machine_context?(:event)
            raise InvalidContext, "Valid only in 'event' block"
          end
          event_name   = @is_state_machine[:event][:name]
          event_object = @is_state_machine[:event][:object]

          from = options[:from]
          to   = options[:to]
          via  = options[:via]
          event_object.add_transition(from, to, via)
        end

      end # EventDsl
    end # StateMachine
  end # Is
end # DataMapper
