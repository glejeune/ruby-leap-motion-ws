# -*- coding: utf-8 -*-
$:.unshift "../lib"

require 'rubygems'
begin
  require 'rubyosa'
rescue LoadError
  puts "Please install rubyosa19"
  exit 0
end

require 'leap-motion-ws'

class Track
  def initialize(itunes)
    @itunes = itunes
    @track = nil
    @change = false
    track
  end

  def name
    track.name
  end

  def artist
    track.artist
  end

  def album
    track.album
  end

  def next
    @itunes.next_track
    @change = true
  end

  def previous
    @itunes.previous_track
    @change = true
  end

  def playpause
    @itunes.playpause
  end

  def change?
    track
    c = @change 
    @change = false
    return c
  end

  def playing?
    track.enabled?
  end

  def to_s
    "#{name} by #{artist} - #{album}"
  end

  private
  def track
    t = @itunes.current_track
    if @track.nil? or t.name != @track.name or t.artist != @track.artist or t.album != @track.album
      @change = true
      @track = t
    end
    return @track
  end
end

class ITunesController < LEAP::Motion::WS
  def initialize
    @itunes = OSA.app('iTunes')
    @track = Track.new @itunes

    @last = true
    @last_time = 0
    super
  end

  def on_connect
    puts "Connect"
  end

  def on_frame frame
    if @track.change?
      puts "Playing : #{@track}"
    end
    unless frame.timestamp.nil?
      delay = frame.timestamp - @last_time
      if frame.hands.size == 1 and @last and delay > 1100000
        @last_time = frame.timestamp
        case frame.pointables.size
        when 0 then @track.playpause
        when 2 then @track.next
        when 4..5 then @track.previous
        end
        @last = false
      elsif frame.hands.size == 0
        @last = true
      end
    end
  end

  def on_disconnect
    puts "Disconect"
    stop
  end
end

puts <<EOF
itunes_controller - by Grégoire Lejeune

Usage :

  * 0 finger : play/pause
  * 2 fingers : next track
  * 4 (or more) fingers : prevous track

Enjoy!

EOF
leap = ITunesController.new()

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
