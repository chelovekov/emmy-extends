require "mysql2"

module EmmyExtends
  module Mysql2
    autoload :Operation,  "emmy_extends/mysql2/operation"
    autoload :Client,     "emmy_extends/mysql2/client"
    autoload :Watcher,    "emmy_extends/mysql2/watcher"
  end
end
