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
    attr_reader :headers
    attr_reader :body

    # required for adapter

    def delegate=(operation)
      @operation = operation
      prepare_url
      @headers = operation.request.headers.clone
      prepare_body
      setup_http_request
      setup_http_client
    end

    def prepare_url
      @url = operation.request.real_url
      raise 'relative url' if url.relative?

      @url.normalize!

      if path = operation.request.real_path
        raise 'path is not relative' unless path.relative?
        @url += path
      end
      @url.user     = operation.request.user if operation.request.user
      @url.password = operation.request.password if operation.request.password
      if operation.request.query
        if operation.request.query.is_a?(Hash)
          @url.query_values = operation.request.query
        else
          @url.query = operation.request.query.to_s
        end
      end
    end

    def prepare_body
      raise "attribute `file` unsupported" if operation.request.file
      body, form, json, file = operation.request.body, operation.request.form, operation.request.json

      @body = if body
        raise "body cannot be hash" if body.is_a?(Hash)
        body_text = body.is_a?(Array) ? body.join : body.to_s
        body_text

      elsif form
        form_encoded = form.is_a?(String) ? form : URI.encode_www_form(form)
        # rfc3986
        body_text = form_encoded.gsub(/([!'()*]+)/m) { '%'+$1.unpack('H2'*$1.bytesize).join('%').upcase }

        headers['Content-Type'] = 'application/x-www-form-urlencoded'
        headers['Content-Length'] = body_text.bytesize
        body_text

      elsif json
        json_string = json.is_a?(String) ? json : (json.respond_to?(:to_json) ? json.to_json : JSON.dump(json))
        headers['Content-Type']   = 'application/json'
        headers['Content-Length'] = json_string.size
        json_string

      else
        headers['Content-Length'] = 0 if %w('POST PUT').include? operation.request.type
        '' # empty body
      end
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
        keepalive: operation.request.keep_alive,
        path: url.path,
        query: url.query,
        body: encode_body(body),
        head: headers
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
      # return EventMachine::HttpConnection
      @http_request = EventMachine::HttpRequest.new(url, connection_options)
    end

    def status
      (@http_client.error || @http_client.response_header.empty?) ? 0 : @http_client.response_header.status
    end
  end
end
