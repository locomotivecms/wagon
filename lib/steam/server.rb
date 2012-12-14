require "steam/server/middleware"
require "steam/server/index"
require "steam/server/not_found"

module Steam
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