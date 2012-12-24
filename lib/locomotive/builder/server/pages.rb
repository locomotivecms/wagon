module Locomotive::Builder
  class Server
    class Pages < Middleware
      def call(env)
        requested = env['PATH_INFO'].gsub(/^\//, '')
        if env["steam.mounting_point"].pages.has_key?(requested)
          [200, {'Content-Type' => 'text/html'}, [env["steam.mounting_point"].pages[requested].source]]
        else
          super
        end
      end
    end
  end
end