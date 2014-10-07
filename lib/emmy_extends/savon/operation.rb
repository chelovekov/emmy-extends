module EmmyExtends
  class Savon::Operation
    using EventObject

    attr_reader :request
    attr_reader :response
    attr_reader :httpi
    attr_reader :globals
    attr_reader :locals

    events :success, :error

    def initialize(httpi, globals, locals)
      @httpi = httpi
      @request = httpi.request
      @globals = globals
      @locals = locals
      setup
    end

    def connect
      @httpi.connect
    end

    def sync
      Fiber.sync do |fiber|
        connect

        on :success do |response, savon, conn|
          fiber.resume response
        end

        on :error do |error, savon, conn|
          # FIXME: TimeoutError separate
          fiber.leave EmmyHttp::ConnectionError, error.to_s
        end
      end
    end

    def setup
      @httpi.on :success do |response, httpi, conn|
        @response = ::Savon::Response.new(response, globals, locals)
        unless @response.soap_fault
          unless @response.http_error
            success!(@response, self, conn)
          else
            error!("HTTP error (#{@response.http.code})", self, conn)
          end
        else
          error!("SOAP error (#{@response.soap_fault.to_s})", self, conn)
        end
      end

      @httpi.on :error do |error, httpi, conn|
        @connection = conn
        error!(error, self, conn)
      end
    end
  end
end
