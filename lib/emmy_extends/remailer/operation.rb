module EmmyExtends
  class Remailer::Operation
    using EventObject

    attr_accessor :request
    attr_accessor :response
    attr_accessor :connection
    attr_accessor :completed
    events :success, :error

    def initialize(req)
      @request = req
      @completed = false
    end

    def connect
      @connection ||= EmmyMachine.connect(*self)
    end

    def send_emails
      raise "no emails to send" if request.emails.empty?

      request.emails.each_with_index do |email, index|
        if index.zero?
          connection.send_email(email.from, email.to, email.content) do |status|
            @response = Remailer::Response.new(status)
            success!(response, self, connection) unless completed
          end
        else
          connection.send_email(email.from, email.to, email.content)
        end
      end
    end

    def sync
      Fiber.sync do |fiber|
        connect
        send_emails

        on :success do |res, operation, conn|
          @completed = true
          fiber.resume response
        end

        on :error do |error, operation, conn|
          @completed = true
          fiber.leave error
        end
      end
    end

    def initialize_connection(conn)
      conn.on :connect do |*a|
      end

      conn.on :error do |*a|
        error!
      end

      conn.on :disconnect do |*a|
        error!(Remailer::Error.new(conn.error_message)) unless completed
      end
    end

    def to_a
      ["tcp://#{request.options.host}:#{request.options.port}", EmmyExtends::Remailer::Connection, method(:initialize_connection), self]
    end

    #<<<
  end
end
