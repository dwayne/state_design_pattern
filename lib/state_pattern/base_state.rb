module StatePattern

  class BaseState

    attr_reader :state_machine

    def initialize(state_machine)
      @state_machine = state_machine
    end

    def self.def_actions(*actions)
      define_method(:actions) do
        actions
      end

      actions.each do |action|
        def_action(action)
      end
    end

    def self.def_action(action_name)
      define_method(action_name) do |*args|
        raise IllegalStateException
      end
    end
  end

  class IllegalStateException < StandardError; end
end
