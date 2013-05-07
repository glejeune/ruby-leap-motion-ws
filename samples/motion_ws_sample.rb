$:.unshift "../lib"

require 'leap-motion-ws'

class LeapTest < LEAP::Motion::WS
  def on_connect
    puts "Connect"
  end

  def on_frame frame
    puts "Frame ##{frame.id}, timestamp: #{frame.timestamp}, hands: #{frame.hands.size}, pointables: #{frame.pointables.size}"
    frame.gestures.each do |gesture|
      puts "  -> #{gesture.type} / #{gesture.state}"
    end
  end

  def on_disconnect
    puts "disconect"
    stop
  end
end

leap = LeapTest.new(:enable_gesture => true)

Signal.trap("TERM") do
  puts "Terminating..."
  leap.stop
end
Signal.trap("KILL") do
  puts "Terminating..."
  leap.stop
end
Signal.trap("INT") do
  puts "Terminating..."
  leap.stop
end

leap.start
