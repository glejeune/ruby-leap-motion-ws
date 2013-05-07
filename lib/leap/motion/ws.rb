require 'rubygems'
require 'websocket-eventmachine-client'
require 'json'
require 'leap/motion/ws/frame'

module LEAP
  class Motion
    class WS
      def initialize(options = {})
        @options = {:uri => "ws://127.0.0.1:6437", :enable_gesture => false}.merge(options)
        @gesture_enables = false
        @ws = nil
      end

      def gestures?
        @gesture_enables
      end

      def gesture!
        unless @ws.nil?
          data = JSON "enableGestures" => true
          @gesture_enables = @ws.send data
        end
      end

      def start(enable_gesture = false)
        EM.run do
          @ws = WebSocket::EventMachine::Client.connect(:uri => @options[:uri])

          @ws.onopen do
            on_connect if respond_to? :on_connect
            gesture! if enable_gesture or @options[:enable_gesture]
          end

          @ws.onmessage do |msg, type|
            message = JSON(msg)
            if message.key?("id") and message.key?("timestamp")
              on_frame LEAP::Motion::WS::Frame.new(message) 
            end
          end

          @ws.onerror do |err|
            on_error(err) if respond_to? :on_error
          end

          @ws.onclose do
            on_disconnect if respond_to? :on_disconnect
          end
        end
      end

      def stop
        EM::stop_event_loop
      end
    end
  end
end

