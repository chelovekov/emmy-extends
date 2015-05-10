require 'thin'

module EmmyExtends
  module Thin
    EMMY_BACKEND = File.expand_path('../thin/rackup.rb', __FILE__)
  end
end

require "emmy_extends/thin/connection"
require "emmy_extends/thin/backend"
require "emmy_extends/thin/controller"
