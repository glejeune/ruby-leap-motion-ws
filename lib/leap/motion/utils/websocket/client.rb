require 'leap/motion/utils/websocket/base'

module LEAP
  class Motion
    module Utils
      module WebSocket
        class Client 
          def initialize(uri)
            @uri = uri
            @running = false
            @unsend_messages = []
          end

          def onopen(&b)
            @on_open = b
          end

          def onmessage(&b)
            @on_message = b
          end

          def onerror(&b)
            @on_error = b
          end

          def onclose(&b)
            @on_close = b
          end

          def send(data)
            if @base
              @base.send(data)
            else
              @unsend_messages << data
            end
          end

          def run
            return if @running

            yield if block_given?

            @running = true
            @base ||= LEAP::Motion::Utils::WebSocket::Base.new(@uri)
            @on_connect.call if @on_connect

            while data = @unsend_messages.shift
              send(data)
            end

            while @running
              @base.receive.each do |message|
                if message.error?
                  @on_error.call(message.to_s) if @on_error
                else
                  @on_message.call(message.to_s, message.type)
                end
              end
            end

            @base.close
            @on_close.call if @on_close
          end

          def stop
            @running = false
          end
        end
      end
    end
  end
end
