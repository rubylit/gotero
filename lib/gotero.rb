# La principal funcion de gotero es ofrecer al usuario comprensión sobre los
# llamados realizados por la aplicación para ententer la interacción entre los
# objetos.
#
# Para hacerlo la idea es ejecutar un bloque de código con un gotero, el cual
# pone luego a disposición un diagrama de secuencias.
# 
# Entonces lo primero va a ser definir una clase Gotero

class Gotero

  # Inicialmente la secuencia va a estar vacía y nuestro primer objeto va a ser
  # un sujeto `:t` (ya que se me ocurre que esto lo estamos corriendo como un
  # test)
  def initialize
    @messages = []
    @emiters = [:t]
  end

  # La interface publica de gotero simplemente recibe un bloque y lo ejecuta con
  # el gotero habilitado
  def trace &block
    tracer.enable &block
  end

  # Para construir la secuencia, unimos los mensajes en orden. Agrego un salto
  # de linea al final para que sea más fácil de leer.
  def output
    @messages.join("\n") << "\n"
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
    subject = module_name receiver
    method = tracepoint.method_id
    detached_method = receiver.instance_method(method)
    arguments = detached_method.parameters.map do |param|
      tracepoint.binding.local_variable_get(param[1]).inspect
    end.join(', ')
    message_details = " #{ method } (#{ arguments })"
    @messages << "#{ current_emiter }->#{ subject }:#{ message_details }"
    @emiters << subject.to_sym
  end

  # El nombre de la clase que recive lo podemos sacar usando el método `name` de
  # `Module`, pero cuando las clases son abstractas no hay un nombre y name es
  # nil.
  def module_name module_object
    if module_object.name
      module_object.name.downcase
    else
      module_object.to_s
    end
  end

  # En el caso del return el receptor es el que está pen-último en la pila, así
  # que lo que hacemos es sacar el último de la pila (y dejarlo como emisor) y
  # tomar como receptor al que queda último.
  def on_return tracepoint
    emiter = @emiters.pop
    receiver = @emiters.last
    @messages << "#{ emiter }-->#{ receiver }:"
  end
end
