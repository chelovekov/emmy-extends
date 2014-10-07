module ActiveRecord
  class ConnectionPool < EM::Synchrony::ConnectionPool

    def execute(async)
      f = Fiber.current
      begin
        conn = acquire(f)
        conn.acquired_for_connection_pool += 1
        yield conn
      ensure
        conn.acquired_for_connection_pool -= 1
        release(f) if !async && conn.acquired_for_connection_pool == 0
      end
    end

    def acquire(fiber)
      return @reserved[fiber.object_id] if @reserved[fiber.object_id]
      super
    end

    def connection
      acquire(Fiber.current)
    end

    def affected_rows(*args, &blk)
      execute(false) do |conn|
        conn.send(:affected_rows, *args, &blk)
      end
    end
  end
end
