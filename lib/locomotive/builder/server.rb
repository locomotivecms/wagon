require 'rack/showexceptions'
require 'coffee_script'

require 'locomotive/mounter'

require 'locomotive/builder/listen'
require 'locomotive/builder/server/middleware'
require 'locomotive/builder/server/favicon'
require 'locomotive/builder/server/dynamic_assets'
require 'locomotive/builder/server/entry_submission'
require 'locomotive/builder/server/path'
require 'locomotive/builder/server/locale'
require 'locomotive/builder/server/page'
require 'locomotive/builder/server/templatized_page'
require 'locomotive/builder/server/not_found'
require 'locomotive/builder/server/renderer'

require 'locomotive/builder/liquid'
require 'locomotive/builder/misc'

module Locomotive::Builder
  class Server

    def initialize(reader)
      Locomotive::Builder::Dragonfly.setup!(reader.mounting_point.path)

      @reader = reader
      @app    = self.create_rack_app(@reader)

      Locomotive::Builder::Listen.instance.start(@reader)
    end

    def call(env)
      env['builder.mounting_point'] = @reader.mounting_point
      @app.call(env)
    end

    protected

    def create_rack_app(reader)
      Rack::Builder.new do
        use Rack::ShowExceptions
        use Rack::Lint

        use Rack::Session::Cookie, {
          key:          'rack.session',
          domain:       '0.0.0.0',
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
        use DynamicAssets

        use EntrySubmission

        use Path
        use Locale

        use Page
        use TemplatizedPage
        use NotFound
        use Renderer

        run Renderer.new
      end
    end

  end
end