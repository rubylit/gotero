require 'pp'

class Knowledge
  def ask string
    q = Question.new "?"
    ! q.well_formed?
  end
end

class Question
  def initialize string
  end

  def well_formed?
  end
end

expected_output = <<SEQUML
t->knowledge: ask (1)
knowledge->question: initialize (?)
question->knowledge:
knowledge->question: well_formed? ()
question->knowledge:
knowledge->t:
SEQUML

class Gotero
  attr_accessor :output

  def initialize
    @output = ''
    @emiters = [:t]
  end

  def tracer
    @trace ||= TracePoint.new(:call, :return) do |tp|
      self.output += "#{formatter(tp)}\n"
    end
  end

  def trace &block
    tracer.enable &block
  end

  def formatter tracepoint
    case tracepoint.event
    when :call
      current_emiter = @emiters.last
      receiver = tracepoint.defined_class
      subject = receiver.name.downcase
      @emiters << subject.to_sym
      method = tracepoint.method_id
      detached_method = receiver.instance_method(method)
      arguments = detached_method.parameters.map do |param|
        tracepoint.binding.local_variable_get param[1]
      end.join(', ')
      message_details = " #{ method } (#{ arguments })"
    when :return
      current_emiter = @emiters.pop
      subject = @emiters.last
    else
      raise
    end
    "#{ current_emiter }->#{ subject }:#{ message_details }"
  end
end

gotero = Gotero.new

gotero.trace do 
  Knowledge.new.ask 1
end

# assert_equal expected_output.lines.size, gotero.output.lines.size
expected_output.lines.zip(gotero.output.lines).each do |expected, actual|
  assert_equal actual, expected
end
