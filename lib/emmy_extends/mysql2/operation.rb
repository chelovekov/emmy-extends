module EmmyExtends
  class Mysql2::Operation
    using EventObject
    events :success, :error

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def watch
      @watch ||= EmmyMachine.watch(*self)
    end

    def sync
      Fiber.sync do |fiber|
        watch

        on :success do |response, operation, conn|
          fiber.resume response
        end

        on :error do |error, operation, conn|
          fiber.leave error
        end
      end
    end

    def to_a
      [client.socket, Mysql2::Watcher, @client, self, {notify_readable: true, notify_writable: false}]
    end

    #<<<
  end
end
