module Locomotive::Builder
  class Server

    class DynamicAssets < Middleware

      def call(env)
        self.set_accessors(env)

        path = env['PATH_INFO']

        if path =~ /^\/(stylesheets|javascripts)\//

          mime_type = MIME::Types.type_for(path).first.try(:to_s) || 'text/plain'
          asset     = self.mounting_point.theme_assets.detect do |_asset|
            _asset.path == path
          end

          if asset
            [200, { 'Content-Type' => mime_type }, [asset.content]]
          else
            [404, { 'Content-Type' => mime_type }, ['Asset not found']]
          end
        else
          app.call(env)
        end
      end

    end

  end
end