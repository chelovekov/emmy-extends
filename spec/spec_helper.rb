require 'bundler/setup'
Bundler.setup

#require File.expand_path("./lib/emmy_extends")
require "emmy_machine"
require "emmy_http"
require "fibre"

using EventObject
Fibre.pool.on :error do |e|
  raise e
end

RSpec.configure do |config|
  config.color = true
end
