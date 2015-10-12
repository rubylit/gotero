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
