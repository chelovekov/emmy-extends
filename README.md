# Emmy::Extends

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'em-http-request' # if em-http-request required
gem 'httpi'           # if httpi required
gem 'mysql2'          # if mysql2 required
gem 'savon', github: 'chelovekov/savon' # if savon required
gem 'emmy-extends'
```

## Usage EmHttpRequest

```ruby
require 'emmy_extends/em_http_request'

EmmyMachine.run_block do
  using Fibre::Synchrony
  request = EmmyHttp::Request.new(
    type: 'get',
    url: 'http://github.com'
  )
  operation1 = EmmyHttp::Operation.new(request, EmmyExtends::EmHttpRequest::Adapter.new)
  operation2 = EmmyHttp::Operation.new(request, EmmyExtends::EmHttpRequest::Adapter.new)
  response = [operation1, operation2].sync
end
```

## Usage HTTPI

```ruby
require 'emmy_extends/httpi'

EmmyMachine.run_block do
  request = HTTPI.post("http://example.com", "bangarang", :emmy)
  response = request.sync
end
```

## Usage Savon

```ruby
require 'emmy_extends/savon'

EmmyMachine.run_block do
  savon = EmmyExtends::Savon
  client = savon.client(wsdl: "http://example.com?wsdl")
  request = client.call(:authenticate) do
    message username: "luke", password: "secret"
    convert_request_keys_to :camelcase
  end
  response = request.sync
end
```

or,

```ruby
require 'emmy_extends/savon'

class User
  include EmmyExtends::Savon::Model

  client wsdl: "http://example.com?wsdl"
  global :basic_auth, "luke", "secret"

  operations :authenticate, :find_user
end
user = User.new
response = user.authenticate(message: { username: "luke", secret: "secret" }).sync
```

## Usage Thin

```ruby
require 'emmy_extends/thin'

class Application < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end

EmmyMachine.run do
  app = Rack::Builder.new do
    use Rack::Logger
    run Application
  end

  EmmyMachine.bind(*EmmyExtends::Thin.server("tcp://localhost:65535", app, options))
end
```

## Usage Mysql2

```ruby
require 'benchmark'
require 'emmy_extends/mysql2'

EmmyMachine.run_block do
  conn1 = EmmyExtends::Mysql2::Client.new
  conn2 = EmmyExtends::Mysql2::Client.new
  puts Benchmark.measure {
    using Fibre::Synchrony
    [conn1.query("SELECT sleep(1) as mysql2_query"), conn2.query("SELECT sleep(2) as mysql2_query")].sync
  }
end
```
