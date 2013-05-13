module LEAP
  class Motion
    class WS
      # Recognized movement by the user
      #
      # There is 4 Gesture subclasses :
      #
      #   Circle - A circular movement by a finger.
      #   Swipe - A straight line movement by the hand with fingers extended.
      #   KeyTap -  A downward tapping movement by a finger.
      #   ScreenTap - A forward tapping movement by a finger.
      class Gesture
        class Error < StandardError; end

        def self.list(data)
          gestures = []
          if data["gestures"]
            data["gestures"].each do |gesture|
              gestures << make_gesture(gesture)
            end
          end
          return gestures
        end

        def self.make_gesture(data)
          unless data.has_key? "type"
            raise Error, "gesture type unknown"
          end
          name = data["type"][0].upcase << data["type"][1..-1]
          unless class_exists?(name)
            raise Error, "gesture class `#{self}::#{name}' invalid"
          end
          const_get(name).new(data)
        end

        private

        def self.class_exists?(class_name)
          klass = const_get(class_name)
          return klass.is_a?(Class)
        rescue NameError
          return false
        end

        def self.define_gesture *names
          names.each do |n|
            name = n.to_s
            unless class_exists?(name)
              c = Class.new(self) do
                def initialize(data)
                  data.each do |k, v|
                    instance_variable_set("@#{k}", v)
                    self.class.send(:define_method, k.to_sym, lambda { instance_variable_get("@#{k}") })
                  end
                end
              end
              const_set name, c
            end
          end
        end

        define_gesture :Circle, :KeyTap, :ScreenTap, :Swipe
      end
    end
  end
end
