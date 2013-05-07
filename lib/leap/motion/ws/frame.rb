require 'leap/motion/ws/gesture'
require 'leap/motion/ws/pointable'
require 'leap/motion/ws/hand'

module LEAP
  class Motion
    class WS
      class Frame
        attr_reader :gestures, :pointables, :hands, :id, :timestamp, :r, :s, :t
        def initialize(data)
          @hands = LEAP::Motion::WS::Hand.list(data)
          @gestures = LEAP::Motion::WS::Gesture.list(data)
          @pointables = LEAP::Motion::WS::Pointable.list(data)
          @id = data["id"]
          @timestamp = data["timestamp"]
          @r = data["r"]
          @s = data["s"]
          @t = data["t"]
        end
      end
    end
  end
end

