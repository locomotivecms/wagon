module Locomotive::Wagon
  class Server

    # Mimic the submission of a content entry
    #
    class EntrySubmission < Middleware

      def call(env)
        self.set_accessors(env)

        if slug = get_content_type_slug(env)
          self.process_form(slug)

          self.navigation_behavior(env)
        else
          self.fetch_submitted_entry

          app.call(env)
        end
      end

      # Render or redirect depending on:
      # - the status of the content entry (valid or not)
      # - the presence of a callback or not
      # - the type of response asked by the browser (html or json)
      #
      def navigation_behavior(env)
        if @entry.valid?
          navigation_success(env)
        else
          navigation_error(env)
        end
      end

      def navigation_success(env)
        if self.html?
          self.record_submitted_entry
          self.redirect_to success_location
        elsif self.json?
          self.json_response
        end
      end

      def navigation_error(env)
        if self.html?
          if error_location =~ %r(^http://)
            self.redirect_to error_location
          else
            env['PATH_INFO'] = error_location
            self.liquid_assigns[@content_type.slug.singularize] = @entry
            app.call(env)
          end
        elsif self.json?
          self.json_response(422)
        end
      end

      protected

      def success_location; location(:success); end
      def error_location; location(:error); end

      def location(state)
        params[:"#{state}_callback"] || (entry_submissions_path? ? '/' : path_info)
      end

      def entry_submissions_path?
        !(path_info =~ %r(^/entry_submissions/)).nil?
      end

      # Get the slug (or permalink) of the content type either from the PATH_INFO variable (old way)
      # or from the presence of the content_type_slug param (model_form tag).
      #
      def get_content_type_slug(env)
        if request.post? && (path_info =~ %r(^/entry_submissions/(.*)) || params[:content_type_slug])
          $1 || params[:content_type_slug]
        end
      end

      # Record in session the newly "persisted" content entry.
      #
      def record_submitted_entry
        session[:now] ||= {}
        session[:now][:submitted_entry] = [@content_type.slug, @entry._slug]
      end

      def fetch_submitted_entry
        if data = session[:now].try(:delete, :submitted_entry)
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
      # @param [ String ] slug The slug (or permalink) of the content type
      #
      #
      def process_form(slug)
        slug = slug.split('.').first

        @content_type = self.mounting_point.content_types[slug]

        raise "Unknown content type '#{@content_type.inspect}'" if @content_type.nil?

        attributes = self.params[:entry] || self.params[:content] || {}

        @entry = @content_type.build_entry(attributes)

        # if not valid, we do not need to keep track of the entry
        @content_type.entries.delete(@entry) if !@entry.valid?
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

        [status, { 'Content-Type' => 'application/json' }, [hash.to_json]]
      end

    end

  end
end