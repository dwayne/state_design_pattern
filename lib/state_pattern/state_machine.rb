require 'forwardable'
require 'observer'

module StatePattern

  class StateMachine
    extend Forwardable
    include Observable

    def initialize
      initialize_context
      transition_to_start_state
      setup_delegation
    end

    def initialize_context
      @ctx = initial_context
    end

    def transition_to_start_state
      transition_to_state(start_state)
    end

    def transition_to_state(state_class)
      @state = state_class.new(self)
    end

    def setup_delegation
      setup_context_delegation
      setup_action_delegation
    end

    def setup_context_delegation
      if @ctx
        methods = @ctx.members.map { |reader| [reader, "#{reader}=".to_sym] }.flatten
        self.class.def_delegators :@ctx, *methods
      end
    end

    def setup_action_delegation
      methods = @state.actions
      self.class.def_delegators :@state, *methods
    end

    def transition_to_state_and_send_event(state_class, name, message = {})
      transition_to_state(state_class)
      send_event(name, message)
    end

    def send_event(name, message = {})
      event = { name: name, source: self }.merge(message)

      changed
      notify_observers(event)

      self
    end

    def initial_context
    end

    def start_state
      raise NotImplementedError
    end
  end
end
