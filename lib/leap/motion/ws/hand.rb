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
          data.each do |k, v|
            instance_variable_set("@#{k}", v)
            self.class.send(:define_method, k.to_sym, lambda { instance_variable_get("@#{k}") })
          end
        end
      end
    end
  end
end
