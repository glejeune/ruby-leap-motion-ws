$:.unshift "../lib"

require 'leap/motion/utils/ring'

x = Ring.new(3)

x << "A"
x << "B"
x << "C"
p x

x << "D"
p x

x << "E"
p x

x << "F"
p x
