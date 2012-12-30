module Locomotive::Builder
  class Server

    class Middleware

      attr_accessor :app, :request

      attr_accessor :mounting_point, :page

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        app.call(env)
      end

      protected

      def set_accessors(env)
        self.request        = Rack::Request.new(env)
        self.mounting_point = env['builder.mounting_point']
        self.page           = env['builder.page']
      end

      def site
        self.mounting_point.site
      end

      def params
        self.request.params
      end

    end

  end
end