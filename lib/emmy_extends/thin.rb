module EmmyExtends
  module Thin
    EMMY_BACKEND = File.expand_path('../thin/rackup.rb', __FILE__)

    autoload :Connection,   "emmy_extends/thin/connection"
    autoload :Backend,      "emmy_extends/thin/backend"
    autoload :Controller,   "emmy_extends/thin/controller"
  end
end
