module EmmyExtends
  class ActiveRecord::Adapter < ::ActiveRecord::ConnectionAdapters::Mysql2Adapter
    def configure_connection
      nil
    end

    def transaction(*args, &blk)
      @connection.execute(false) do |conn|
        super
      end
    end

    def real_connection
      @connection.connection
    end

    def open_transactions
      real_connection.open_transactions
    end

    def increment_open_transactions
      real_connection.open_transactions += 1
    end

    def decrement_open_transactions
      real_connection.open_transactions -= 1
    end

    def current_transaction #:nodoc:
      @transaction[Fiber.current.object_id] || @closed_transaction
    end

    def transaction_open?
      current_transaction.open?
    end

    def begin_transaction(options = {}) #:nodoc:
      set_current_transaction(current_transaction.begin(options))
    end

    def commit_transaction #:nodoc:
      set_current_transaction(current_transaction.commit)
    end

    def rollback_transaction #:nodoc:
      set_current_transaction(current_transaction.rollback)
    end

    def reset_transaction #:nodoc:
      @transaction = {}
      @closed_transaction = ::ActiveRecord::ConnectionAdapters::ClosedTransaction.new(self)
    end

    # Register a record with the current transaction so that its after_commit and after_rollback callbacks
    # can be called.
    def add_transaction_record(record)
      current_transaction.add_record(record)
    end

    protected

    def set_current_transaction(t)
      if t == @closed_transaction
        @transaction.delete(Fiber.current.object_id)
      else
        @transaction[Fiber.current.object_id] = t
      end
    end
  end
end
