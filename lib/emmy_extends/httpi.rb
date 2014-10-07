require "emmy_extends/em_http_request"
require "httpi"

module EmmyExtends
  module HTTPI
    require "emmy_extends/httpi/adapter"
    autoload :Operation,  "emmy_extends/httpi/operation"
  end
end
