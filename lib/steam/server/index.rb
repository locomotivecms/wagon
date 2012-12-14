module Steam
  class Server
    class Index < Middleware
      def call(env)
        if env['PATH_INFO'] == '/'
          [404, {'Content-Type' => 'text/html'}, [env["steam.mounting_point"].pages["index"].source]]
        else
          super
        end
      end
    end
  end
end