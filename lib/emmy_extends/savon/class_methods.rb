# Example,
#   client = Savon.client do
#     endpoint "http://example.com"
#     namespace "http://v1.example.com"
#   end
#   response = client.call(:authenticate, message: { username: "luke", password: "secret" }).sync
#
module EmmyExtends
  module Savon::ClassMethods
    def client(globals = {}, &block)
      globals[:response_class] = Savon::Operation
      globals[:raise_errors] = false
      ::Savon::Client.new(globals, &block)
    end
  end
end
