# La principal funcion de gotero es ofrecer al usuario comprensión sobre los
# llamados realizados por la aplicación para ententer la interacción entre los
# objetos.
#
# Para hacerlo la idea es ejecutar un bloque de código con un gotero, el cual
# pone luego a disposición un diagrama de secuencias.
# 
# Entonces lo primero va a ser definir una clase Gotero

class Gotero
  
  # Por el momento, vamos a guardar el resultado como un string y lo vamos a
  # hacer accesible, después vamos a ver como podemos guardar esta información
  # de una forma más adaptada a nuestras necesidades.
  attr_accessor :output

  # Inicialmente la secuencia va a estar vacía y nuestro primer objeto va a ser
  # un sujeto `:t` (ya que se me ocurre que esto lo estamos corriendo como un
  # test)
  def initialize
    @output = ''
    @emiters = [:t]
  end

  # La interface publica de gotero simplemente recibe un bloque y lo ejecuta con
  # el gotero habilitado
  def trace &block
    tracer.enable &block
  end

  # Más allá de esa interface pública, el resto es privado
  private

  # Para hacer el seguimiento, lo que vamos a usar es `TracePoint` al cual, si
  # le pasamos un bloque ejecuta el bloque cada vez que un evento del tipo
  # indicado se realiza.
  #
  # Los eventos que nos interesan son `call` y `return`, o sea llamados a
  # métodos y retornos de métodos.
  def tracer
    TracePoint.new(:call, :return) do |tp|
      case tp.event
      when :call then on_call(tp)
      when :return then on_return(tp)
      end
    end
  end

  # Cuando se hace un llamado a un método necesitamos saber quien lo llamó y
  # quien es el receptor, para guardamos la pila de emisores, el receptor de un
  # mensaje siempre es el emisor del siguiente mensaje, excepto en el caso en
  # que un mensaje vuelva.
  #
  # Además de emisor y receptor, necesitamos saber el método que estamos
  # llamando y, ya que estamos, los argumentos con los que se llama al método.
  def on_call tracepoint
    current_emiter = @emiters.last
    receiver = tracepoint.defined_class
    subject = receiver.name.downcase
    method = tracepoint.method_id
    detached_method = receiver.instance_method(method)
    arguments = detached_method.parameters.map do |param|
      tracepoint.binding.local_variable_get(param[1]).inspect
    end.join(', ')
    message_details = " #{ method } (#{ arguments })"
    self.output << "#{ current_emiter }->#{ subject }:#{ message_details }\n"
    @emiters << subject.to_sym
  end

  # En el caso del return el receptor es el que está pen-último en la pila, así
  # que lo que hacemos es sacar el último de la pila (y dejarlo como emisor) y
  # tomar como receptor al que queda último.
  def on_return tracepoint
    emiter = @emiters.pop
    receiver = @emiters.last
    self.output << "#{ emiter }->#{ receiver }:\n"
  end
end
