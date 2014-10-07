module EmmyExtends
  module Mysql2::Watcher

    attr_accessor :client, :operation

    def initialize(client, operation)
      @client = client
      @operation = operation
    end

    def notify_readable
      detach
      begin
        result = @client.async_result
      rescue Exception => e
        @operation.error!(e.to_s, @operation, self)
      else
        @operation.success!(result, @operation, self)
      end
    end

    #<<<
  end
end
