module EmmyExtends
  module Thin::ClassMethods
    using CoreExt

    def server(url, app, opt={})
      Thin::Controller.new(url, app, opt.to_options).start
    end
  end
end
