require_relative '../lib/gotero'

class Knowledge
  def ask string
    q = Question.new "una pregunta?"
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
knowledge->question: initialize ("una pregunta?")
question-->knowledge:
knowledge->question: well_formed? ()
question-->knowledge:
knowledge-->t:
SEQUML

gotero = Gotero.new

gotero.trace do 
  Knowledge.new.ask 1
end

assert_equal expected_output, gotero.output
