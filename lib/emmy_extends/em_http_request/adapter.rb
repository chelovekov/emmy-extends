module EmmyExtends
  class EmHttpRequest::Adapter < EmmyHttp::Adapter
    using EventObject

    attr_reader :http_request
    attr_reader :http_client
    attr_reader :body
    attr_reader :connection

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
      delegate.init!(delegate, conn)

    rescue EventMachine::ConnectionError => e
      EventMachine.next_tick { @http_client.close(e.message) }
      delegate.error!("connection error", self)
    end

    def connection_options
      {
        connect_timeout: delegate.request.timeouts.connect,
        inactivity_timeout: delegate.request.timeouts.inactivity,
        :ssl => (delegate.request.ssl?) ? {
          :cert_chain_file => delegate.request.ssl.cert_chain_file,
          :verify_peer => (delegate.request.ssl.verify_peer == :peer)
        } : {}
      }
    end

    def request_options
      {
        redirects: 5,
        keepalive: false,
        path: delegate.request.url.path,
        query: delegate.request.url.query,
        body: encode_body(delegate.request.body),
        head: delegate.request.headers
      }
    end

    def encode_body(body)
      return body if delegate.request.headers["Content-Encoding"] != "gzip"
      wio = StringIO.new("w")
      begin
        w_gz = Zlib::GzipWriter.new(wio)
        w_gz.write(body)
        wio.string
      ensure
        w_gz.close
      end
    end

    def setup
      raise 'delegator must be set before' unless delegate
      setup_http_request
      setup_http_client
    end

    def setup_http_client
      @http_client = begin
        method = delegate.request.method.to_s.upcase
        http_client_options = HttpClientOptions.new(delegate.request.url, request_options, method)
        EventMachine::HttpClient.new(@http_request, http_client_options).tap do |client|
          client.stream do |chunk|
            @body << chunk
          end

          client.headers do |response_header|
            delegate.head!(delegate, connection)
          end

          client.callback do
            if @http_client.response_header && @http_client.response_header.status.zero?
              delegate.error!("connection timed out", delegate, connection)
            else
              delegate.success!(delegate.response, delegate, connection)
            end
          end

          client.errback do |c|
            delegate.error!(client.error, delegate, connection)
          end
        end
      end
    end

    def setup_http_request
      @http_request = EventMachine::HttpRequest.new(delegate.request.url, connection_options)
    end

    def to_a
      ["tcp://#{delegate.request.url.host}:#{delegate.request.url.port}", EmmyMachine::Connection, method(:initialize_connection), self]
    end

    def headers
      @http_client.response_header
    end

    def status
      (@http_client.error || @http_client.response_header.empty?) ? 0 : @http_client.response_header.status
    end
  end
end
