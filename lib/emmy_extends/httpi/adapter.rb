module EmmyExtends
  class HTTPI::Adapter < ::HTTPI::Adapter::Base
    register :emmy

    attr_reader :client

    def initialize(request)
      @request = request
    end

    def setup_http_auth
      unless @request.auth.type == :basic
        raise NotSupportedError, "EM-HTTP-Request does only support HTTP basic auth"
      end
      @http_request.headers[:authorization] = @request.auth.credentials
    end

    def proxy_options
      {
        :host          => @request.proxy.host,
        :port          => @request.proxy.port,
        :authorization => [@request.proxy.user, @request.proxy.password]
      }
    end

    def request(type)
      if @request.on_body
        raise NotSupportedError, "EM-HTTP-Request does not support response streaming"
      end

      if @request.ssl?
        ssl = {
          cert_chain_file: @request.auth.ssl.ca_cert_file,
          verify_peer: @request.auth.ssl.verify_mode,
          ssl_version: @request.auth.ssl.ssl_version
        }
      end

      @http_request = EmmyHttp::Request.new(
        url: build_request_url(@request.url),
        type: type,
        timeouts: { connect: @request.open_timeout, inactivity: @request.read_timeout },
        headers: @request.headers.to_hash,
        body: @request.body,
        ssl: ssl
      )

      # FIXME: proxy support # proxy_options if @request.proxy
      #setup_proxy(options) if @request.proxy
      setup_http_auth if @request.auth.http?

      @http_operation = EmmyHttp::Operation.new(@http_request, EmmyExtends::EmHttpRequest::Adapter.new)
      @operation = HTTPI::Operation.new(@http_operation)
      @operation
    end

    def build_request_url(url)
      "%s://%s:%s%s" % [url.scheme, url.host, url.port, url.path]
    end

    #<<<
  end
end
