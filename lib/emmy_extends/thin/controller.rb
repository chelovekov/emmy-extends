module EmmyExtends
  class Thin::Controller < ::Thin::Controllers::Controller

    attr_accessor :app
    attr_accessor :config
    attr_accessor :server
    attr_accessor :backend

    def initialize(config, app, opts={})
      @app = app
      @config = config.is_a?(Hash) ? EmmyHttp::Configuration.new(config) : config
      options = {
        environment: config.environment,
        address:   config.url.host,
        port:      config.url.port,
        pid:       config.pid,
        log:       config.log,
        daemonize: config.daemonize
      }
      super(option_defaults.merge(options.merge(opts)))
      setup
    end

    def start
    end

    def setup
      if @options[:socket]
        @server = ::Thin::Server.new(@options[:socket], @options)
      else
        @server = ::Thin::Server.new(config.url.host, config.url.port, @options)
      end
      server.backend.url = config.url

      # Set options
      server.pid_file                       = @options[:pid]
      server.log_file                       = @options[:log]
      server.timeout                        = @options[:timeout]
      server.maximum_connections            = @options[:max_conns]
      server.maximum_persistent_connections = @options[:max_persistent_conns]
      server.threaded                       = @options[:threaded]
      server.no_epoll                       = @options[:no_epoll] if server.backend.respond_to?(:no_epoll=)
      server.threadpool_size                = @options[:threadpool_size] if server.threaded?

      # ssl support
      if @options[:ssl]
        server.ssl = true
        server.ssl_options = {
          private_key_file: @options[:ssl_key_file],
          cert_chain_file: @options[:ssl_cert_file],
          verify_peer: !@options[:ssl_disable_verify]
        }
      end

      # Detach the process, after this line the current process returns
      server.daemonize if @options[:daemonize]

      # +config+ must be called before changing privileges since it might require superuser power.
      server.config

      server.change_privilege @options[:user], @options[:group] if @options[:user] && @options[:group]

      server.app = app

      #server.on_restart { Thin::Command.run(:start, @options) }

      # just return thin-backend
      @backend = server.backend
    end

    def to_a
      @backend.to_a
    end

    private

    def option_defaults
      {
        backend:              EmmyExtends::Thin::Backend,
        threaded:             false,
        no_epoll:             false,
        chdir:                Dir.pwd,
        environment:          'development',
        address:              '0.0.0.0',
        port:                 3434,
        timeout:              0, #sec
        pid:                  "tmp/pids/server.pid",
        log:                  File.join(Dir.pwd, "log/server.log"),
        max_conns:            1024,
        max_persistent_conns: 100,
        require:              [],
        wait:                 0, #sec
        daemonize:            false
      }
    end
  end
end
