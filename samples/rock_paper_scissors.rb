$:.unshift "../lib"

require 'leap-motion-ws'

class LeapTest < LEAP::Motion::WS
  def initialize
    @last = nil
    @last_time = 0
    @elements = ["rock", "paper", "scissors"]
    @results = [ 0, -1, 1, 1, 0, -1, -1, 1, 0 ]
    super
  end

  def result human, machine
    @results[(@elements.index(human) * 3) + @elements.index(machine)]
  end

  def on_connect
    puts "Connect"
  end

  def on_frame frame
    unless frame.timestamp.nil?
      delay = frame.timestamp - @last_time
      if frame.hands.size == 1 and @last.nil? and delay > 1100000
        @last_time = frame.timestamp
        @last = case frame.pointables.size
                when 0..1 then "rock"
                when 2 then "scissors"
                when 3..5 then "paper"
                end
        ia_choise = @elements.sample
        print "You: #{@last}, Me: #{ia_choise} - "
        case result(@last, ia_choise)
        when -1 then puts "I win !"
        when 1 then puts "You win !"
        else puts "Draw"
        end
      elsif frame.hands.size == 0
        @last = nil
      end
    end
  end

  def on_disconnect
    puts "disconect"
    stop
  end
end

leap = LeapTest.new()

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
