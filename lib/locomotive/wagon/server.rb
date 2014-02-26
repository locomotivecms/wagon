require 'better_errors'
require 'coffee_script'

require 'locomotive/wagon/listen'
require 'locomotive/wagon/server/middleware'
require 'locomotive/wagon/server/favicon'
require 'locomotive/wagon/server/dynamic_assets'
require 'locomotive/wagon/server/logging'
require 'locomotive/wagon/server/entry_submission'
require 'locomotive/wagon/server/path'
require 'locomotive/wagon/server/locale'
require 'locomotive/wagon/server/page'
require 'locomotive/wagon/server/timezone'
require 'locomotive/wagon/server/templatized_page'
require 'locomotive/wagon/server/renderer'

require 'locomotive/wagon/liquid'
require 'locomotive/wagon/misc'

module Locomotive::Wagon
  class Server

    def initialize(reader, options = {})
      Locomotive::Wagon::Dragonfly.setup!(reader.mounting_point.path)

      Sprockets::Sass.add_sass_functions = false

      @reader = reader
      @app    = self.create_rack_app(@reader)

      BetterErrors.application_root = reader.mounting_point.path
    end

    def call(env)
      env['wagon.mounting_point'] = @reader.mounting_point
      @app.call(env)
    end

    protected

    def create_rack_app(reader)
      Rack::Builder.new do
        use Rack::Lint

        use BetterErrors::MiddlewareWrapper

        use Rack::Session::Cookie, {
          key:          'wagon.session',
          path:         '/',
          expire_after: 2592000,
          secret:       'uselessinlocal'
        }

        use ::Dragonfly::Middleware, :images

        use Rack::Static, {
          urls: ['/images', '/fonts', '/samples'],
          root: File.join(reader.mounting_point.path, 'public')
        }

        use Favicon
        use DynamicAssets, reader.mounting_point.path

        use Logging

        use EntrySubmission

        use Path
        use Locale
        use Timezone

        use Page
        use TemplatizedPage

        run Renderer.new
      end
    end

  end
end
