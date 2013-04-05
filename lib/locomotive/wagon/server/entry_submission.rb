module Locomotive::Wagon
  class Server

    # Mimic the submission of a content entry
    #
    class EntrySubmission < Middleware

      def call(env)
        self.set_accessors(env)

        if self.request.post? && env['PATH_INFO'] =~ /^\/entry_submissions\/(.*)/
          self.process_form($1)

          # puts "html? #{html?} / json? #{json?} / #{self.callback_url} / #{params.inspect}"

          if @entry.valid?
            if self.html?
              self.record_submitted_entry
              self.redirect_to self.callback_url
            elsif self.json?
              self.json_response
            end
          else
            if self.html?
              if self.callback_url =~ /^http:\/\//
                self.redirect_to self.callback_url
              else
                env['PATH_INFO'] = self.callback_url
                self.liquid_assigns[@content_type.slug.singularize] = @entry
                app.call(env)
              end
            elsif self.json?
              self.json_response(422)
            end
          end
        else
          self.fetch_submitted_entry

          app.call(env)
        end
      end

      protected

      def record_submitted_entry
        self.request.session[:now] ||= {}
        self.request.session[:now][:submitted_entry] = [@content_type.slug, @entry._slug]
      end

      def fetch_submitted_entry
        if data = self.request.session[:now].try(:delete, :submitted_entry)
          content_type = self.mounting_point.content_types[data.first.to_s]

          entry = (content_type.entries || []).detect { |e| e._slug == data.last }

          # do not keep track of the entry
          content_type.entries.delete(entry) if entry

          # add it to the additional liquid assigns for the next liquid rendering
          if entry
            self.liquid_assigns[content_type.slug.singularize] = entry
          end
        end
      end

      # Mimic the creation of a content entry with a minimal validation.
      #
      # @param [ String ] permalink The permalink (or slug) of the content type
      #
      #
      def process_form(permalink)
        permalink = permalink.split('.').first

        @content_type = self.mounting_point.content_types[permalink]

        raise "Unknown content type '#{@content_type.inspect}'" if @content_type.nil?

        attributes = self.params[:entry] || self.params[:content] || {}

        @entry = @content_type.build_entry(attributes)

        # if not valid, we do not need to keep track of the entry
        @content_type.entries.delete(@entry) if !@entry.valid?
      end

      def callback_url
        (@entry.valid? ? params[:success_callback] : params[:error_callback]) || '/'
      end

      # Build the JSON response
      #
      # @param [ Integer ] status The HTTP return code
      #
      # @return [ Array ] The rack response depending on the validation status and the requested format
      #
      def json_response(status = 200)
        locale = self.mounting_point.default_locale

        if self.request.path =~ /^\/(#{self.mounting_point.locales.join('|')})+(\/|$)/
          locale = $1
        end

        hash = @entry.to_hash(false).tap do |_hash|
          if !@entry.valid?
            _hash['errors'] = @entry.errors.inject({}) do |memo, name|
              memo[name] = ::I18n.t('errors.messages.blank', locale: locale)
              memo
            end
          end
        end

        [status, { 'Content-Type' => 'application/json' }, [
          { @content_type.slug.singularize => hash }.to_json
        ]]
      end

    end

  end
end