module Locomotive::Builder
  class Server

    class Favicon < Middleware

      def call(env)
        if env['PATH_INFO'] == '/favicon.ico'
          [200, { 'Content-Type' => 'image/vnd.microsoft.icon' }, ['']]
        else
          app.call(env)
        end
      end

    end

  end
end