require 'em-http-request'

module EmmyExtends
  module EmHttpRequest
    autoload :Connection, "emmy_extends/em_http_request/connection"
    autoload :Adapter,    "emmy_extends/em_http_request/adapter"
  end
end
