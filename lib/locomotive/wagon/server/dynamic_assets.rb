module Locomotive::Wagon
  class Server

    class DynamicAssets < Middleware

      attr_reader :app, :sprockets, :regexp

      def initialize(app, root)
        super(app)

        @regexp = /^\/(javascripts|stylesheets)\/(.*)$/

        # make sure Compass is correctly configured
        Locomotive::Mounter::Extensions::Compass.configure(root)

        @sprockets = Sprockets::Environment.new
        @sprockets.append_path File.join(root, 'public/stylesheets')
        @sprockets.append_path File.join(root, 'public/javascripts')
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