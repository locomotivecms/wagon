module Locomotive::Wagon
  class Server

    class Middleware

      attr_accessor :app, :request, :path, :liquid_assigns

      attr_accessor :mounting_point, :page, :content_entry

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        app.call(env)
      end

      protected

      def set_accessors(env)
        self.path           = env['wagon.path']
        self.request        = Rack::Request.new(env)
        self.mounting_point = env['wagon.mounting_point']
        self.page           = env['wagon.page']
        self.content_entry  = env['wagon.content_entry']

        env['wagon.liquid_assigns'] ||= {}
        self.liquid_assigns = env['wagon.liquid_assigns']
      end

      def site
        self.mounting_point.site
      end

      def params
        self.request.params.deep_symbolize_keys
      end

      def html?
        self.request.media_type == 'text/html' || !self.request.xhr?
      end

      def json?
        self.request.content_type == 'application/json' || File.extname(self.request.path) == '.json'
      end

      def redirect_to(location, type = 301)
        self.log "Redirected to #{location}"
        [type, { 'Content-Type' => 'text/html', 'Location' => location }, []]
      end

      def log(msg)
        Locomotive::Wagon::Logger.info msg
      end

    end

  end
end