require "remailer"

module EmmyExtends
  module Remailer
    class Error < StandardError; end

    autoload :Operation,  "emmy_extends/remailer/operation"
    autoload :Connection,     "emmy_extends/remailer/connection"
    autoload :Request,    "emmy_extends/remailer/request"
    autoload :Response,    "emmy_extends/remailer/response"
    autoload :Options,    "emmy_extends/remailer/request/options"
    autoload :Email,    "emmy_extends/remailer/request/email"
  end
end
