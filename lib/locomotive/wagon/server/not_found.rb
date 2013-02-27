module Locomotive::Wagon
  class Server

    class NotFound < Middleware

      def call(env)
        self.set_accessors(env)

        if self.page.nil?
          self.log "Page not found"
          env['wagon.page'] = self.mounting_point.pages['404']
        end

        app.call(env)
      end

    end
  end
end