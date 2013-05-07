require 'rubygems'
require 'websocket-eventmachine-client'
require 'json'
require 'leap/motion/ws/frame'

module LEAP
  class Motion
    class WS
      def initialize(uri = "ws://127.0.0.1:6437")
        @uri = uri
      end

      def start
        EM.run do
          ws = WebSocket::EventMachine::Client.connect(:uri => @uri)

          ws.onopen do
            on_connect
          end

          ws.onmessage do |msg, type|
            on_frame LEAP::Motion::WS::Frame.new(JSON(msg))
          end

          ws.onclose do
            on_disconnect
          end
        end
      end

      def stop
        EM::stop_event_loop
      end
    end
  end
end

