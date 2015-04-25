using EventObject

module EmmyExtends
  class EmHttpRequest::Adapter
    include EmmyHttp::Adapter

    attr_reader :http_request
    attr_reader :http_client
    attr_reader :body
    attr_reader :connection
    attr_reader :operation
    attr_reader :response
    attr_reader :url

    # required for adapter

    def delegate=(operation)
      @operation = operation
      @url = operation.request.real_url
      setup_http_request
      setup_http_client
    end

    def to_a
      ["tcp://#{url.host}:#{url.port || url.default_port}", EmmyMachine::Connection, method(:initialize_connection), self]
    end

    def initialize_connection(conn)
      @connection = conn
      conn.extend EmHttpRequest::Connection
      @http_request.conn = conn
      @http_request.post_init

      conn.on :connect do
        http_request.connection_completed
      end

      conn.on :data do |chunk|
        http_request.receive_data chunk
      end

      conn.on :close do |reason=nil|
        http_request.unbind(reason)
      end

      # before connection_completed
      @http_request.finalize_request(@http_client)

      conn.pending_connect_timeout = http_request.connopts.connect_timeout
      conn.comm_inactivity_timeout = http_request.connopts.inactivity_timeout

      @body = ''
      #operation.connection = conn  # update connection handler
      operation.init!(operation, conn)

    rescue EventMachine::ConnectionError => e
      EventMachine.next_tick { @http_client.close(e.message) }
      operation.error!("connection error", self)
    end

    def connection_options
      {
        connect_timeout: operation.request.timeouts.connect,
        inactivity_timeout: operation.request.timeouts.inactivity,
        ssl: (operation.request.ssl) ? {
          cert_chain_file: operation.request.ssl.cert_chain_file,
          verify_peer:     (operation.request.ssl.verify_peer == :peer),
          ssl_version:     operation.request.ssl.ssl_version
        } : {}
      }
    end

    def request_options
      {
        redirects: 5,
        keepalive: false,
        path: url.path,
        query: url.query,
        body: encode_body(operation.request.body),
        head: operation.request.headers
      }
    end

    def encode_body(body)
      return body if operation.request.headers["Content-Encoding"] != "gzip"
      wio = StringIO.new("w")
      begin
        w_gz = Zlib::GzipWriter.new(wio)
        w_gz.write(body)
        wio.string
      ensure
        w_gz.close
      end
    end

    def setup_http_client
      @http_client = begin
        type = operation.request.type.to_s.upcase # http method
        http_client_options = HttpClientOptions.new(url, request_options, type)
        EventMachine::HttpClient.new(@http_request, http_client_options).tap do |client|
          client.stream do |chunk|
            @body << chunk
          end

          client.headers do |response_header|
            @response = EmmyHttp::Response.new
            response.headers = http_client.response_header
            response.status  = status
            operation.head!(response, operation, connection)
          end

          client.callback do
            if @http_client.response_header && @http_client.response_header.status.zero?
              operation.error!("connection timed out", operation, connection)
            else
              response.body   = body
              operation.success!(response, operation, connection)
            end
          end

          client.errback do |c|
            operation.error!(client.error, operation, connection)
          end
        end
      end
    end

    def setup_http_request
      @http_request = EventMachine::HttpRequest.new(url, connection_options)
    end

    def status
      (@http_client.error || @http_client.response_header.empty?) ? 0 : @http_client.response_header.status
    end
  end
end
