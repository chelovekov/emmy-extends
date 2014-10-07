require "emmy_extends/httpi"
require "savon"

module EmmyExtends
  module Savon
    autoload :ClassMethods, "emmy_extends/savon/class_methods"
    autoload :Operation,    "emmy_extends/savon/operation"
    autoload :Model,        "emmy_extends/savon/model"

    extend ClassMethods
  end
end
