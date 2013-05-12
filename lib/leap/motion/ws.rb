require 'rubygems'
require 'websocket-eventmachine-client'
require 'json'
require 'leap/motion/ws/frame'
require 'leap/motion/utils/history'

module LEAP
  class Motion
    # Public: Class to be subclassed to interface with the Leap Motion
    #
    # Example
    #
    #   class MyLeap < LEAP::Motion::WS
    #     def initialize(...)
    #       #...
    #     end
    #
    #     def on_frame(frame)
    #       # ...
    #     end
    #
    #     def on_connect
    #       # ...
    #     end
    #
    #     def on_disconnect
    #       # ...
    #     end
    #
    #     def on_error(message)
    #       # ...
    #     end
    #   end
    #
    # on-frame is the only mandatory function.
    class WS
      # Public: Initialize a LEAP::Motion::WS 
      #
      # options - The Hash options used to initialize the Leap access (default: {:uri => "ws://127.0.0.1:6437", :enable_gesture => false, :history_size => 1000}):
      #       :uri - the String uri for the WebSocket::EventMachine::Client connection (optional)
      #       :enable_gesture - boolean to indicate if we want to enable gesture or not (optional)
      #       :history_size : the Integer size of the history ()
      def initialize(options = {})
        @options = {:uri => "ws://127.0.0.1:6437", :enable_gesture => false, :history_size => 1000}.merge(options)
        @history = LEAP::Motion::Utils::History.new(@options[:history_size])
      end

      # Public: Return true if gestures are enabled, false otherwise
      def gestures?
        options[:enable_gesture] 
      end

      # Public: Return the Frame History
      def history
        @history ||= LEAP::Motion::Utils::History.new(options[:history_size])
      end

      # Public: Enable gestures
      #
      # Return nothing.
      def gesture!
        unless @ws.nil?
          data = JSON "enableGestures" => true
          options[:enable_gesture] = ws.send data
        end
      end

      # Public: Start the interface
      #
      # enable_gesture : boolean to indicate if we want to enable gesture or not (default: false)
      #
      # Examples
      #
      #   class MyLeap < LEAP::Motion::WS
      #     ...
      #   end
      #   MyLeap.new.start
      #
      # Returns self
      def start(enable_gesture = false)
        EM.run do
          ws.onopen do
            on_connect if respond_to? :on_connect
            gesture! if enable_gesture or options[:enable_gesture]
          end

          ws.onmessage do |msg, type|
            message = JSON(msg)
            if message.key?("id") and message.key?("timestamp")
              frame = LEAP::Motion::WS::Frame.new(message)
              history << frame
              on_frame frame
            end
          end

          ws.onerror do |err|
            on_error(err) if respond_to? :on_error
          end

          ws.onclose do
            on_disconnect if respond_to? :on_disconnect
          end
        end

        return self
      end

      # Public: Start the interface
      #
      # enable_gesture : boolean to indicate if we want to enable gesture or not (default: false)
      #
      # Examples
      #
      #   class MyLeap < LEAP::Motion::WS
      #     ...
      #   end
      #   MyLeap.start
      #
      # Returns the LEAP::Motion::WS subclass object
      def self.start(enable_gesture = false)
        _leap = new
        _leap.start(enable_gesture)
      end


      # Public: Stop the interface
      #
      # Examples
      #
      #   class MyLeap < LEAP::Motion::WS
      #     ...
      #   end
      #   my_leap = MyLeap.start
      #   ...
      #   my_leap.stop
      #
      # Returns self
      def stop
        EM::stop_event_loop
      end

      private

      # private: Get the options hash
      def options
        @options ||= {:uri => "ws://127.0.0.1:6437", :enable_gesture => false, :history_size => 1000}
      end

      # Private: Get the WebSocket::EventMachine::Client connection
      def ws
        @ws ||= WebSocket::EventMachine::Client.connect(:uri => options[:uri])
      end
    end
  end
end

