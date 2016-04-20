$LOAD_PATH << File.join(__dir__, '../lib')

require 'differ'
Differ.format = :color

def assert_equal expected, actual
  super
rescue
  puts Differ.diff expected, actual
  raise
end
