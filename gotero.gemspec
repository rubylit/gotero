Gem::Specification.new do |s|
  s.name        = 'gotero'
  s.version     = '0.2.0'
  s.licenses    = ['AGPL-3.0+']
  s.summary     = 'Sequence diagrams from runtime.'
  s.description = 'Use a tracer to build a sequence diagram of a block of code.'
  s.authors     = ['RubyLit']
  s.email       = 'rubylitar@gmail.com'
  s.files       = ['lib/gotero.rb']
  s.homepage    = 'https://github.com/rubylit/gotero'

  s.add_development_dependency 'differ'
end


