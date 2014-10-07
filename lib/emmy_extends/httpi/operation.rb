module EmmyExtends
  class HTTPI::Operation
    using EventObject

    attr_reader :request
    attr_reader :response
    attr_reader :connection
    attr_reader :http

    events :success, :error

    def initialize(http)
      @http = http
      @request = http.request
      setup
    end

    def connect
      http.connect
    end

    def sync
      Fiber.sync do |fiber|
        connect

        on :success do |response, operation, conn|
          fiber.resume response
        end

        on :error do |error, operation, conn|
          # FIXME: TimeoutError separate
          fiber.leave ConnectionError, error.to_s
        end
      end
    end

    def setup
      http.on :init do |connection|
        @connection = connection
      end

      http.on :success do |res, http, conn|
        @response = ::HTTPI::Response.new(*res)
        success!(response, self, conn)
      end

      http.on :error do |error, http, conn|
        error!(error, self, conn)
      end
    end

    def code
      0
    end

    def follow_redirect?
      false
    end
  end
end
