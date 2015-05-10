require "thin"
require "emmy_extends/thin"

config = Emmy::Runner.instance.config
app    = Rack::Adapter.for(Rack::Adapter.guess(Chdir.pwd), { environment: config.environment })

Emmy.run do
  puts "Thin web server"
  puts "Listening on #{app.config.url}"
  Emmy.bind *EmmyExtends::Thin::Controller.new(config, app)
end
