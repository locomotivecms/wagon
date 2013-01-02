module Locomotive::Builder
  class Server

    class Middleware

      attr_accessor :app, :request, :path

      attr_accessor :mounting_point, :page, :content_entry

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        app.call(env)
      end

      protected

      def set_accessors(env)
        self.path           = env['builder.path']
        self.request        = Rack::Request.new(env)
        self.mounting_point = env['builder.mounting_point']
        self.page           = env['builder.page']
        self.content_entry  = env['builder.content_entry']
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