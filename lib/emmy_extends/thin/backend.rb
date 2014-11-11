require 'thin'

module EmmyExtends
  class Thin::Backend < ::Thin::Backends::Base
    attr_accessor :url

    def initialize(host, port, options)
      super()
    end

    def connect
      raise "deprecated. you should start server through emmy.bind"
    end

    def start
      raise "deprecated. you should start server through emmy.bind"
    end

    # Stops the server
    def disconnect
      puts "disconnect"
      #EventMachine.stop_server(@signature)
    end

    def initialize_connection(conn)
      @stopping = false
      thin_connection = ::Thin::Connection.new(conn.signature)
      thin_connection.backend = self
      conn.delegate = thin_connection
      super(thin_connection)
      @running = true # FIXME: maybe not here
      conn.delegate.post_init
    end

    def to_a
      [url, EmmyExtends::Thin::Connection, method(:initialize_connection)]
    end

    def to_s
      "#{@host}:#{@port}"
    end
  end
end
