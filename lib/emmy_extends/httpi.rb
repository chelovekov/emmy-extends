require "emmy_extends/em_http_request"
require "httpi"

# TLS FIX:
class HTTPI::Auth::SSL
  attr_writer :ssl_version
end

#DISABLE GZIP
class HTTPI::Response
  def gzipped_response?
    false
  end
end

module EmmyExtends
  module HTTPI
    require "emmy_extends/httpi/adapter"
    autoload :Operation,  "emmy_extends/httpi/operation"
  end
end
