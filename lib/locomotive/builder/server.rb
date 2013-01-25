require "locomotive/builder/server/middleware"
require "locomotive/builder/server/index"
require "locomotive/builder/server/not_found"

module Locomotive::Builder
  class Server
    def initialize(reader)
      @reader = reader
      @app = Rack::Builder.new do
         use Rack::Lint
         use Index
         run NotFound.new
       end
    end
    
    def call(env)
      env["steam.mounting_point"] = @reader.mounting_point
      @app.call(env)
    end
  end
end