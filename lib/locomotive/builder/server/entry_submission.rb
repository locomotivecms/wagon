module Locomotive::Builder
  class Server

    # Mimic the submission of a content entry
    #
    #
    class EntrySubmission < Middleware

      def call(env)
        self.set_accessors(env)

        if self.request.post? && self.path =~ /^entry_submissions\/(.*)/
          self.process_form($1)

          # TODO
          [200, { 'Content-Type' => 'text/html' }, ["POST !!! #{$1}"]]
        else
          app.call(env)
        end
      end

      protected

      # Mimic the creation of a content entry with a minimal validation.
      #
      # @param [ String ] permalink The permalink (or slug) of the content type
      #
      # @return [ Array ] The rack response depending on the validation status and the requested format
      #
      def process_form(permalink)
        content_type = self.mounting_point.content_types[permalink]

        raise "Unknown content type '#{content_type.inspect}'" if content_type.nil?

        puts "params = #{self.params.inspect}"

        content_entry = self.build_entry(content_type, self.params[:entry] || self.params[:content])

        if content_entry.valid?
          puts "valid content entry!"
        else
          puts "invalid content entry!"
        end
      end

      def build_entry(content_type, attributes)
        Locomotive::Mounter::Models::ContentEntry.new(content_type: content_type).tap do |entry|
          # do not forget that we are manipulating dynamic fields
          attributes.each { |k, v| entry.send(:"#{k}=", v) }

          # force the slug to be defined from its label and in all the locales
          entry.send :set_slug
        end
      end

    end

  end
end