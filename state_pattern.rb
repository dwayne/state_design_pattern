# An implementation of the State Design Pattern in Ruby.
#
# See http://sourcemaking.com/design_patterns/state
#
# written by Dwayne R. Crooks (me@dwaynecrooks.com)

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
      transition_to_state(start_state_class)
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

    def start_state_class
      raise NotImplementedError
    end
  end

  class BaseState

    attr_reader :state_machine

    def initialize(state_machine)
      @state_machine = state_machine
    end

    def self.def_action(action_name)
      define_method(action_name) do |*args|
        raise IllegalStateException
      end
    end

    def self.def_actions(*actions)
      define_method(:actions) do
        actions
      end

      actions.each do |action|
        def_action(action)
      end
    end
  end

  class IllegalStateException < StandardError; end
end

# Example 1
#
# See http://sourcemaking.com/design_patterns/state/java/1

class CeilingFanPullChain < StatePattern::StateMachine
  def start_state_class
    Off
  end
end

class CeilingFanState < StatePattern::BaseState
  def_actions :pull
end

class Off < CeilingFanState
  def pull
    puts "-> low speed"
    state_machine.transition_to_state(Low)
  end
end

class Low < CeilingFanState
  def pull
    puts "-> medium speed"
    state_machine.transition_to_state(Medium)
  end
end

class Medium < CeilingFanState
  def pull
    puts "-> high speed"
    state_machine.transition_to_state(High)
  end
end

class High < CeilingFanState
  def pull
    puts "-> turning off"
    state_machine.transition_to_state(Off)
  end
end

def example1
  chain = CeilingFanPullChain.new

  loop do
    print "Press "
    gets.chomp
    chain.pull
  end
end

# Example 2
#
# See http://sourcemaking.com/design_patterns/state/java/6

class FSM < StatePattern::StateMachine
  def start_state_class
    A
  end
end

class FSMState < StatePattern::BaseState
  def_actions :on, :off, :ack
end

class A < FSMState
  def on
    puts "A + on = C"
    state_machine.transition_to_state(C)
  end

  def off
    puts "A + off = B"
    state_machine.transition_to_state(B)
  end

  def ack
    puts "A + ack = A"
    state_machine.transition_to_state(A)
  end
end

class B < FSMState
  def on
    puts "B + on = A"
    state_machine.transition_to_state(A)
  end

  def off
    puts "B + off = C"
    state_machine.transition_to_state(C)
  end
end

class C < FSMState
  def on
    puts "C + on = B"
    state_machine.transition_to_state(B)
  end
end

def example2
  fsm = FSM.new

  [2, 1, 2, 1, 0, 2, 0, 0].each do |msg|
    begin
      fsm.on  if msg == 0
      fsm.off if msg == 1
      fsm.ack if msg == 2
    rescue StatePattern::IllegalStateException
      puts "error"
    end
  end
end
