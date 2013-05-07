module LEAP
  class Motion
    class WS
      class Gesture
        def self.list(data)
          gestures = []
          if data["gestures"]
            data["gestures"].each do |gesture|
              gestures << LEAP::Motion::WS::Gesture.new(gesture)
            end
          end
          return gestures
        end

        def initialize(data)
          @data = data
        end

        def method_missing(mid)
          @data[mid.id2name]
        end
      end
    end
  end
end
