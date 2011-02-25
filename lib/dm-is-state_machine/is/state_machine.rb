module DataMapper
  module Is
    module StateMachine

      class InvalidContext  < RuntimeError; end
      class InvalidState    < RuntimeError; end
      class InvalidEvent    < RuntimeError; end
      class EventConfusion  < RuntimeError; end
      class DuplicateStates < RuntimeError; end
      class NoInitialState  < RuntimeError; end

      ##
      # Makes a column ('state' by default) act as a state machine. It will
      # define the property if it does not exist.
      #
      # @example [Usage]
      #   is :state_machine
      #   is :state_machine, :initial => :internal
      #   is :state_machine, :column => :availability
      #   is :state_machine, :column => :availability, :initial => :external
      #
      # @param options<Hash> a hash of options
      #
      # @option :column<Symbol> the name of the custom column
      #
      def is_state_machine(options = {}, &block)
        extend DataMapper::Is::StateMachine::EventDsl
        extend DataMapper::Is::StateMachine::StateDsl
        include DataMapper::Is::StateMachine::InstanceMethods

        # ===== Setup context =====
        options = { :column => :state, :initial => nil }.merge(options)
        column  = options[:column]
        initial = options[:initial].to_s
        unless properties.detect { |p| p.name == column }
          property column, String, :default => initial
        end
        definition = Data::MachineDefinition.new(column, initial)
        @is_state_machine = { :definition => definition }

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{column}=(value)
            value = value.to_s if value.kind_of?(Symbol)
            attribute_set(#{column.inspect}, value)
          end
        RUBY

        # ===== Define callbacks =====
        # TODO: define callbacks
        # before :save do
        #   if self.new_record?
        #     # ...
        #   else
        #     # ...
        #   end
        # end

        before :destroy do
          if state_machine.find_event(:destroy)
            transition!(:destroy)
          end
        end

        # ===== Setup context =====
        push_state_machine_context(:is)

        yield if block_given?

        # ===== Teardown context =====
        pop_state_machine_context
      end

      def inherited(base)
        super
        base.class_eval do
          @is_state_machine = superclass.instance_variable_get(:@is_state_machine)
        end
      end

      protected

      def push_state_machine_context(label)
        @is_state_machine ||= {}
        @is_state_machine[:context] ||= []
        @is_state_machine[:context] << label

        # Compacted, but barely readable for humans
        # ((@is_state_machine ||= {})[:context] ||= []) << label
      end

      def pop_state_machine_context
        @is_state_machine[:context].pop
      end

      def state_machine_context?(label)
        (i = @is_state_machine) && (c = i[:context]) &&
        c.respond_to?(:include?) && c.include?(label)
      end

      module InstanceMethods

        def initialize(*args)
          super
          # ===== Run :enter hook if present =====
          state_machine.run_initial
        end

        def transition!(event_name)
          state_machine.fire_event(event_name)
        end

        def state_machine
          return unless is_sm = model.instance_variable_get(:@is_state_machine)
          return unless definition = is_sm[:definition]
          Data::Machine.new(definition, self)
        end

      end # InstanceMethods

    end # StateMachine
  end # Is
end # DataMapper

# Notes
# -----
#
# Since this gets mixed into a class, I try to keep the namespace pollution
# down to a minimum.  This is why I only use the @is_state_machine instance
# variable.
