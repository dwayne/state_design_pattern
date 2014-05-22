# state_design_pattern

[![Gem Version](https://badge.fury.io/rb/state_design_pattern.svg)](http://badge.fury.io/rb/state_design_pattern)
[![Build Status](https://travis-ci.org/dwayne/state_design_pattern.svg?branch=master)](https://travis-ci.org/dwayne/state_design_pattern)
[![Coverage Status](https://coveralls.io/repos/dwayne/state_design_pattern/badge.png?branch=master)](https://coveralls.io/r/dwayne/state_design_pattern?branch=master)
[![Code Climate](https://codeclimate.com/github/dwayne/state_design_pattern.png)](https://codeclimate.com/github/dwayne/state_design_pattern)

An implementation of the
[State Design Pattern](http://sourcemaking.com/design_patterns/state) in Ruby.
The State Design Pattern allows an object to alter its behavior when its
internal state changes.

## Example

Here's an example of the state design pattern in use. A light bulb is modeled.
It can be turned on and off. Every time it is turned on it uses 25% of its
energy. When it runs out of energy it cannot be turned on again.

```ruby
class LightBulbContext < Struct.new(:energy, :times_on, :times_off)
end

class LightBulb < StateDesignPattern::StateMachine
  def start_state
    Off
  end

  def initial_context
    LightBulbContext.new(100, 0, 0)
  end
end

class Switch < StateDesignPattern::BaseState
  def_actions :turn_on, :turn_off

  alias_method :light_bulb, :state_machine
end

class On < Switch

  def turn_on
    light_bulb.send_event(:already_turned_on)
  end

  def turn_off
    light_bulb.times_off += 1
    light_bulb.transition_to_state_and_send_event(Off, :turned_off)
  end
end

class Off < Switch

  def turn_on
    if light_bulb.energy >= 25
      light_bulb.energy -= 25
      light_bulb.times_on += 1
      light_bulb.transition_to_state_and_send_event(On, :turned_on)
    else
      light_bulb.send_event(:out_of_energy)
    end
  end

  def turn_off
    light_bulb.send_event(:already_turned_off)
  end
end

class LightBulbObserver

  def initialize
    @events = []
  end

  def last_event
    @events.last
  end

  def update(event)
    @events << event
  end
end

light_bulb = LightBulb.new
light_bulb_observer = LightBulbObserver.new

light_bulb.add_observer(light_bulb_observer)

light_bulb.current_state #=> Off

light_bulb.energy        #=> 100
light_bulb.times_on      #=> 0
light_bulb.times_off     #=> 0

light_bulb.turn_on
light_bulb_observer.last_event[:name] #=> :turned_on

light_bulb.current_state #=> On

light_bulb.energy        #=> 75
light_bulb.times_on      #=> 1
light_bulb.times_off     #=> 0

light_bulb.turn_off
light_bulb.turn_on

light_bulb.turn_off
light_bulb.turn_on

light_bulb.turn_off
light_bulb.turn_on

light_bulb.energy        #=> 0
light_bulb.times_on      #=> 4
light_bulb.times_off     #=> 3

light_bulb.turn_off
light_bulb.turn_on

light_bulb_observer.last_event[:name] #=> :out_of_energy
```

## Testing

You can run:

- All specs: `bundle exec rake`, or
- A specific spec: `bundle exec ruby -Ilib -Ispec spec/path_to_spec_file.rb`

## Contributing

If you'd like to contribute a feature or bugfix: Thanks! To make sure your
fix/feature has a high chance of being included, please read the following
guidelines:

1. Post a [pull request](https://github.com/dwayne/state_design_pattern/compare/).
2. Make sure there are tests! I will not accept any patch that is not tested.
It's a rare time when explicit tests aren't needed. If you have questions about
writing tests for state_pattern, please open a
[GitHub issue](https://github.com/dwayne/state_design_pattern/issues/new).

## License

state_design_pattern is Copyright © 2014 Dwayne R. Crooks. It is free software,
and may be redistributed under the terms specified in the MIT-LICENSE file.
