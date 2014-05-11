#!/usr/bin/env ruby
#
# See http://sourcemaking.com/design_patterns/state/java/1

require 'state_pattern'

class CeilingFanPullChain < StatePattern::StateMachine
  def start_state
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

def main
  chain = CeilingFanPullChain.new

  loop do
    print "Press "
    gets.chomp
    chain.pull
  end
end

main
