require 'rubygems'
require 'websocket-eventmachine-client'
require 'json'
require 'leap/motion/ws/frame'
require 'leap/motion/utils/history'

module LEAP
  class Motion
    # To interface with the Leap Motion, create a subclass of WS :
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
      # Create a new WS instance
      # 
      # Avallables options are :
      # * :uri : URI for the WebSocket (default: ws://127.0.0.1:6437)
      # * :enable_gesture : boolean to indicate if we want to enable gesture or not (default: false)
      # * :history_size : Size of the history (default: 1000)
      def initialize(options = {})
        @options = {:uri => "ws://127.0.0.1:6437", :enable_gesture => false, :history_size => 1000}.merge(options)
        @history = LEAP::Motion::Utils::History.new(@options[:history_size])
      end

      # Return true if gesture ar enabled, false otherwise
      def gestures?
        options[:enable_gesture] 
      end

      # Return the history
      def history
        @history ||= LEAP::Motion::Utils::History.new(options[:history_size])
      end

      # Enable gestures
      def gesture!
        unless @ws.nil?
          data = JSON "enableGestures" => true
          options[:enable_gesture] = ws.send data
        end
      end

      # Start the interface
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
      end

      # Stop the interface
      def stop
        EM::stop_event_loop
      end

      private

      # Get options hash
      def options
        @options ||= {:uri => "ws://127.0.0.1:6437", :enable_gesture => false, :history_size => 1000}
      end

      # Return the WebSocket connection
      def ws
        @ws ||= WebSocket::EventMachine::Client.connect(:uri => options[:uri])
      end
    end
  end
end

