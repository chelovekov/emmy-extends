module EmmyExtends
  class Mysql2::Client < ::Mysql2::Client
    using EventObject

     def query(sql, opts={})
      if ::EventMachine.reactor_running?
        super(sql, opts.merge(:async => true))
        Mysql2::Operation.new(self)
      else
        super(sql, opts)
      end
    end

    def close(*args)
      @watch.detach if @watch
      super(*args)
    end

    #<<<
  end
end
