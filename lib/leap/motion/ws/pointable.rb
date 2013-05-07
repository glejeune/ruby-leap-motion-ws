module LEAP
  class Motion
    class WS
      class Pointable
        def self.list(data)
          pointables = []
          if data["pointables"]
            data["pointables"].each do |pointable|
              pointables << LEAP::Motion::WS::Pointable.new(pointable)
            end
          end
          return pointables
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
