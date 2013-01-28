module Locomotive::Builder
  class Server

    # Track the request into the current logger
    #
    class Logging < Middleware

      def call(env)
        now = Time.now

        log "Started #{env['REQUEST_METHOD'].upcase} \"#{env['PATH_INFO']}\" at #{now}"

        app.call(env).tap do |response|
          done_in_ms = (Time.now - now) * 1000
          log "Completed #{code_to_human(response.first)} in #{done_in_ms}ms\n\n"
        end
      end

      protected

      def code_to_human(code)
        case code.to_i
        when 200 then '200 OK'
        when 301 then '301 Found'
        when 302 then '302 Found'
        when 404 then '404 Not Found'
        end
      end

    end
  end
end