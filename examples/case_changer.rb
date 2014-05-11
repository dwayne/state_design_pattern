#!/usr/bin/env ruby
#
# See http://en.wikipedia.org/wiki/State_pattern#Java

require 'state_pattern'

class CaseChanger < StatePattern::StateMachine
  def start_state
    Lowercase
  end
end

class CaseChangerState < StatePattern::BaseState
  def_actions :write
end

class Lowercase < CaseChangerState
  def write(name)
    puts name.downcase
    state_machine.transition_to_state(MultipleUppercase)
  end
end

class MultipleUppercase < CaseChangerState
  def write(name)
    puts name.upcase
    state_machine.transition_to_state(Lowercase) if incr_count > 1
  end

  private
    def incr_count
      @count = 0 unless @count
      @count += 1
    end
end

def main
  changer = CaseChanger.new

  ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].each do |day|
    changer.write(day)
  end
end

main
