module EmmyExtends
  class Remailer::Connection < ::Remailer::SMTP::Client
    using EventObject

    attr_accessor :operation
    events :connect, :error, :disconnect

    def initialize(op)
      @operation = op
      options = op.request.options.serializable_hash
      options[:on_connect] = lambda { |*a| self.connect!(*a) }
      options[:on_error] = lambda { |*a| self.error!(*a) }
      options[:on_disconnect] = lambda { |*a| self.disconnect!(*a) }
      options[:close] = true

      super(options)
    end

    #<<<
  end
end
