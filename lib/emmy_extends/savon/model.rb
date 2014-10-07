module EmmyExtends
  module Savon::Model
    def self.included(base)
      base.extend ::Savon::Model
      base.global :response_class, Operation
    end
  end
end
