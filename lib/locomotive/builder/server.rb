require 'rack/showexceptions'
require 'locomotive/builder/server/middleware'
require 'locomotive/builder/server/favicon'
require 'locomotive/builder/server/dynamic_assets'
require 'locomotive/builder/server/path'
require 'locomotive/builder/server/locale'
require 'locomotive/builder/server/page'
require 'locomotive/builder/server/not_found'
require 'locomotive/builder/server/renderer'

require 'locomotive/builder/liquid'
require 'locomotive/builder/misc'

module Locomotive::Builder
  class Server

    def initialize(reader)
      @reader = reader
      @app = Rack::Builder.new do
        use Rack::ShowExceptions
        use Rack::Lint

        use Rack::Static, {
          urls: ['/images', '/fonts', '/samples'],
          root: File.join(reader.mounting_point.path, 'public')
        }
        use Favicon
        use DynamicAssets
        use Path
        use Locale
        use Page
        use NotFound
        use Renderer

        run Renderer.new
      end
    end

    def call(env)
      env['builder.mounting_point'] = @reader.mounting_point
      @app.call(env)
    end

  end
end