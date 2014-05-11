#!/usr/bin/env ruby
#
# See http://en.wikipedia.org/wiki/State_pattern#Pseudocode

require 'state_pattern'

class Cursor < StatePattern::StateMachine
  def start_state_class
    PenTool
  end

  def use_pen_tool
    transition_to_state(PenTool)
  end

  def use_selection_tool
    transition_to_state(SelectionTool)
  end
end

class AbstractTool < StatePattern::BaseState
  def_actions :move_to, :mouse_down, :mouse_up
end

class PenTool < AbstractTool
  def move_to(point)
    puts "pen: moving to #{point}"
  end

  def mouse_down(point)
    puts "pen: mouse down at #{point}"
  end

  def mouse_up(point)
    puts "pen: mouse up at #{point}"
  end
end

class SelectionTool < AbstractTool
  def move_to(point)
    if @mouse_button == :down
      puts "selection: current selected rectangle is between #{@selection_start} and #{point}"
    else
      puts "selection: moving to #{point}"
    end
  end

  def mouse_down(point)
    @mouse_button = :down
    @selection_start = point

    puts "selection: mouse down at #{point}"
  end

  def mouse_up(point)
    @mouse_button = :up

    puts "selection: mouse up at #{point}"
  end
end

class Point < Struct.new(:x, :y)
end

def main
  cursor = Cursor.new

  # Draw a line from (1, 1) to (5, 5)
  cursor.use_pen_tool
  cursor.move_to(Point.new(1, 1))
  cursor.mouse_down(Point.new(1, 1))
  cursor.move_to(Point.new(5, 5))
  cursor.mouse_up(Point.new(5, 5))

  # Select part of the line
  cursor.use_selection_tool
  cursor.move_to(Point.new(2, 2))
  cursor.mouse_down(Point.new(2, 2))
  cursor.move_to(Point.new(4, 4))
  cursor.mouse_up(Point.new(4, 4))
end

main
