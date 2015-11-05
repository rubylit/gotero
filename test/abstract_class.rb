require_relative '../lib/gotero'

abstract_module = Module.new do
  def foo
    "bar"
  end
end

abstract_class = Class.new do
  include abstract_module

  def call_foo
    foo
  end
end

subject = abstract_class.new

gotero = Gotero.new
gotero.trace do
  subject.call_foo
end

assert_equal 4, gotero.output.lines.size
gotero.output.lines.each do |line|
  assert line.match(/^.*->.*:.*$/)
end
