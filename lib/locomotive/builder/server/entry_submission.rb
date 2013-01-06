module Locomotive::Builder
  class Server

    # Mimic the submission of a content entry
    #
    #
    class EntrySubmission < Middleware

      def call(env)
        self.set_accessors(env)

        if self.request.post? && self.path =~ /^entry_submissions\/(.*)/
          # TODO
          [200, { 'Content-Type' => 'text/html' }, ['POST !!!']]
        else
          app.call(env)
        end
      end

      protected

    end

  end
end