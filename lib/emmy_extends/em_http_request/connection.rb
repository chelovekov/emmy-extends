module EmmyExtends
  module EmHttpRequest::Connection
    def self.extended(base)
      base.extend EventMachine::Deferrable
    end

    def succeed
      @callback.call
    end

    def callback(&b)
      @callback = b
    end
  end
end
