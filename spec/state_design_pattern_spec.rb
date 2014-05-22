require 'spec_helper'

describe "the operation of the state design pattern with an example" do

  TIMESTAMP = Time.now

  class LightBulbContext < Struct.new(:energy, :times_on, :times_off)
    def blown?
      energy < 25
    end
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
    def_actions :turn_on, :turn_off, :toggle

    alias_method :light_bulb, :state_machine
  end

  class On < Switch

    def turn_on
      light_bulb.send_event(:already_turned_on, when: TIMESTAMP)
    end

    def turn_off
      light_bulb.times_off += 1
      light_bulb.transition_to_state_and_send_event(Off, :turned_off, when: TIMESTAMP)
    end
  end

  class Off < Switch

    def turn_on
      if !light_bulb.context.blown?
        light_bulb.energy -= 25
        light_bulb.times_on += 1
        light_bulb.transition_to_state_and_send_event(On, :turned_on, when: TIMESTAMP)
      else
        light_bulb.send_event(:out_of_energy, when: TIMESTAMP)
      end
    end

    def turn_off
      light_bulb.send_event(:already_turned_off, when: TIMESTAMP)
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

  describe LightBulb do

    let(:light_bulb) { LightBulb.new }
    let(:light_bulb_observer) { LightBulbObserver.new }

    before do
      light_bulb.add_observer(light_bulb_observer)
    end

    describe "the initial state of the bulb" do
      it "is off" do
        light_bulb.current_state.must_equal Off
      end

      it "is full of energy" do
        light_bulb.energy.must_equal 100
      end

      it "has been turned on 0 times" do
        light_bulb.times_on.must_equal 0
      end

      it "has been turned off 0 times" do
        light_bulb.times_off.must_equal 0
      end
    end

    describe "the actions that can be performed on the light bulb" do

      it "can be turned on" do
        light_bulb.must_respond_to :turn_on
      end

      it "can be turned off" do
        light_bulb.must_respond_to :turn_off
      end

      it "can be toggled" do
        light_bulb.must_respond_to :toggle
      end
    end

    describe "how the actions work" do

      describe "in the off state" do

        describe "#turn_on" do

          before do
            light_bulb.turn_on
          end

          it "turns on the bulb" do
            light_bulb.current_state.must_equal On
          end

          it "causes the bulb to use 25% of its energy" do
            light_bulb.energy.must_equal 75
          end

          it "has been turned on 1 time" do
            light_bulb.times_on.must_equal 1
          end

          it "has been turned off 0 times" do
            light_bulb.times_off.must_equal 0
          end

          it "sends a :turned_on event" do
            event = light_bulb_observer.last_event

            event[:name].must_equal :turned_on
            event[:source].must_equal light_bulb
            event[:when].must_equal TIMESTAMP
          end
        end

        describe "#turn_off" do

          before do
            light_bulb.turn_off
          end

          it "keeps the bulb turned off" do
            light_bulb.current_state.must_equal Off
          end

          it "doesn't use any energy" do
            light_bulb.energy.must_equal 100
          end

          it "has been turned on 0 times" do
            light_bulb.times_on.must_equal 0
          end

          it "has been turned off 0 times" do
            light_bulb.times_off.must_equal 0
          end

          it "sends an :already_turned_off event" do
            event = light_bulb_observer.last_event

            event[:name].must_equal :already_turned_off
            event[:source].must_equal light_bulb
            event[:when].must_equal TIMESTAMP
          end
        end

        describe "#toggle" do

          it "doesn't work" do
            proc { light_bulb.toggle }.must_raise StateDesignPattern::IllegalStateException
          end
        end
      end

      describe "in the on state" do

        before do
          light_bulb.turn_on
        end

        describe "#turn_on" do

          before do
            light_bulb.turn_on
          end

          it "keeps the bulb turned on" do
            light_bulb.current_state.must_equal On
          end

          it "doesn't use any energy" do
            light_bulb.energy.must_equal 75
          end

          it "has been turned on 1 time" do
            light_bulb.times_on.must_equal 1
          end

          it "has been turned off 0 times" do
            light_bulb.times_off.must_equal 0
          end

          it "sends an :already_turned_on event" do
            event = light_bulb_observer.last_event

            event[:name].must_equal :already_turned_on
            event[:source].must_equal light_bulb
            event[:when].must_equal TIMESTAMP
          end
        end

        describe "#turn_off" do

          before do
            light_bulb.turn_off
          end

          it "turns off the bulb" do
            light_bulb.current_state.must_equal Off
          end

          it "doesn't use any energy" do
            light_bulb.energy.must_equal 75
          end

          it "has been turned on 1 time" do
            light_bulb.times_on.must_equal 1
          end

          it "has been turned off 1 time" do
            light_bulb.times_off.must_equal 1
          end

          it "sends a :turned_off event" do
            event = light_bulb_observer.last_event

            event[:name].must_equal :turned_off
            event[:source].must_equal light_bulb
            event[:when].must_equal TIMESTAMP
          end
        end

        describe "#toggle" do

          it "doesn't work" do
            proc { light_bulb.toggle }.must_raise StateDesignPattern::IllegalStateException
          end
        end
      end
    end

    describe "how the bulb works when it is out of energy" do

      before do
        # at 100%
        light_bulb.turn_on
        light_bulb.turn_off
        # at 75%
        light_bulb.turn_on
        light_bulb.turn_off
        # at 50%
        light_bulb.turn_on
        light_bulb.turn_off
        # at 25%
        light_bulb.turn_on
        light_bulb.turn_off
        # at 0%
      end

      it "is off" do
        light_bulb.current_state.must_equal Off
      end

      it "is out of energy" do
        light_bulb.energy.must_equal 0
      end

      it "has been turned on 4 times" do
        light_bulb.times_on.must_equal 4
      end

      it "has been turned off 4 times" do
        light_bulb.times_off.must_equal 4
      end

      describe "when you try to turn it on" do

        before do
          light_bulb.turn_on
        end

        it "remains off" do
          light_bulb.current_state.must_equal Off
        end

        it "sends an :out_of_energy energy event" do
          event = light_bulb_observer.last_event

          event[:name].must_equal :out_of_energy
          event[:source].must_equal light_bulb
          event[:when].must_equal TIMESTAMP
        end
      end
    end
  end
end
