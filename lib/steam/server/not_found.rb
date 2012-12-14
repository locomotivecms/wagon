module Steam
  class Server
    class NotFound
      def call(env)
        [404, {'Content-Type' => 'text/html'}, [env["steam.mounting_point"].pages["404"].source]]
      end
    end
  end
end