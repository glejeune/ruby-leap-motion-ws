require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'shoulda'
require 'pathname'

cur = Pathname.new(File.expand_path("..", __FILE__))
lib = cur.join('..', 'lib')

$LOAD_PATH.unshift(lib.to_s, cur.to_s)
require 'leap-motion-ws'

