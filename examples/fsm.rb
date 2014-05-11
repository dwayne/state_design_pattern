#!/usr/bin/env ruby
#
# See http://sourcemaking.com/design_patterns/state/java/6

require 'state_pattern'

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

def main
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

main
