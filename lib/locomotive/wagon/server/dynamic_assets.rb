module Locomotive::Wagon
  class Server

    class DynamicAssets < Middleware

      attr_reader :app, :sprockets, :regexp

      def initialize(app, site_path)
        super(app)

        @regexp     = /^\/(javascripts|stylesheets)\/(.*)$/

        @sprockets  = Locomotive::Mounter::Extensions::Sprockets.environment(site_path)
      end

      def call(env)
        if env['PATH_INFO'] =~ self.regexp
          env['PATH_INFO'] = $2

          begin
            self.sprockets.call(env)
          rescue Exception => e
            raise Locomotive::Wagon::DefaultException.new "Unable to serve a dynamic asset. Please check the logs.", e
          end
        else
          app.call(env)
        end
      end

    end

  end
end
