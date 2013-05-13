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
          data.each do |k, v|
            instance_variable_set("@#{k}", v)
            self.class.send(:define_method, k.to_sym, lambda { instance_variable_get("@#{k}") })
          end
        end
      end
    end
  end
end
