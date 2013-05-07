module LEAP
  class Motion
    class WS
      class Hand
        def self.list(data)
          hands = []
          if data["hands"]
            data["hands"].each do |hand|
              hands << LEAP::Motion::WS::Hand.new(hand)
            end
          end
          return hands
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
