require 'rubygems'
require 'websocket'
require 'socket'
require 'openssl'
require 'uri'

module LEAP
  class Motion
    module Utils
      module WebSocket
        class Base
          class Error < StandardError; end

          def initialize(uri)
            uri = URI.parse(uri)

            if uri.scheme == "ws"
              default_port = 80
            elsif uri.scheme = "wss"
              default_port = 443
            else
              raise Error, "unsupported scheme: #{uri.scheme}"
            end

            socket = TCPSocket.new(uri.host, uri.port || default_port)
            if uri.scheme == "ws"
              @socket = socket
            else
              @socket = sslify(socket)
            end

            @hs = WebSocket::Handshake::Client.new(:uri => uri)
            write @hs.to_s
            flush

            while not @hs.finished?
              @hs << gets
            end 

            raise Error, "connection error: #{@hs.error}" unless @hs.valid?
            @frame = WebSocket::Frame::Incoming::Server.new(:version => @hs.version)
          end

          def close
            begin
              @socket.close
            rescue IOError => e
              puts "Error: #{e}" if debug
            end
          end

          def send(data, type = :text)
            write WebSocket::Frame::Outgoing::Server.new(:version => @hs.version, :data => data, :type => type).to_s
            flush
          end

          def receive
            begin
              data = @socket.read_nonblock(1024)
            rescue 
              IO.select([@socket])
              retry
            end
            @frame << data

            messages = []
            while message = @frame.next
              if message.type === :ping
                send(message.data, :pong)
                return messages
              end
              messages << message
            end
            messages
          rescue IOError, Errno::EBADF
            []
          end

          private

          def debug
            return !ENV["WS_DEBUG"].nil?
          end

          def write(data)
            @socket.write(data)
          end

          def flush
            @socket.flush
          end

          def gets
            return @socket.gets
          end

          def sslify(socket)
            ssl_context = OpenSSL::SSL::SSLContext.new()
            ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
            ssl_socket.sync_close = true
            ssl_socket.connect()
            return ssl_socket
          end
        end
      end
    end
  end
end

require 'pp'
c = Client.new(:uri => "ws://127.0.0.1:6437")
while true
  pp c.receive
end
c.close
