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

diag = []

tracer = Proc.new do |event, file, line, method, binding, class_name|
  if %w[ call return ].include? event
  puts <<-OUT
event:      #{ event }
line:       #{ line }
method:     #{ method }
class_name: #{ class_name }
self:       #{ binding.eval('self') }

OUT

  diag << {:message => method}
  end
end

set_trace_func tracer

Knowledge.new.ask 1

set_trace_func nil

if diag[0][:message] == :ask
  puts 'output the ask'
else
  raise diag.inspect
end
  #   ['knowledge(ask)',
  #                          ['Question(initialize)'],
  #                          'question(well_formed)']
