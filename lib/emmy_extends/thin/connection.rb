module EmmyExtends
  class Thin::Connection < ::EventMachine::Connection
    attr_accessor :delegate

    def unbind(reason=nil)
      @delegate.unbind
    end

    def receive_data(*a)
      @delegate.receive_data(*a)
    end

    # fix me did not works
    def method_missing(name, *a, &b)
      @delegate.send(name, *a, &b)
    end

    #<<<
  end
end
