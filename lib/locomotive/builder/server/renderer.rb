module Locomotive::Builder
  class Server

    class Renderer < Middleware

      def call(env)
        self.set_accessors(env)

        puts "[Builder|Renderer] page = #{page.inspect}"

        if self.page
          if self.page.redirect?
            [self.page.redirect_type, { 'Location' => self.page.redirect_url, 'Content-Type' => 'text/html' }, []]
          else
            type = self.page.response_type || 'text/html'
            html = self.render

            [200, { 'Content-Type' => type }, [html]]
          end
        else
          puts "argggg"
          # no page at all, even not the 404 page
          [404, { 'Content-Type' => 'text/html' }, ['Page not found']]
        end
      end

      protected

      def render
        context = self.locomotive_context

        template = ::Liquid::Template.parse(self.page.source, {
          page:           self.page,
          mounting_point: self.mounting_point
        })

        template.render(context)
      end

      # Build the Liquid context used to render the Locomotive page. It
      # stores both assigns and registers.
      #
      # @param [ Hash ] other_assigns Assigns coming for instance from the controler (optional)
      #
      # @return [ Object ] A new instance of the Liquid::Context class.
      #
      def locomotive_context(other_assigns = {})
        assigns = self.locomotive_default_assigns

        # process data from the session
        # assigns.merge!(self.locomotive_flash_assigns)

        assigns.merge!(other_assigns)

        # TODO: templatized page

        # if defined?(self.page) && self.page.templatized? # add instance from content type
        #   content_entry = self.page.content_entry.to_liquid
        #   ['content_entry', 'entry', @page.target_entry_name].each do |key|
        #     assigns[key] = content_entry
        #   end
        # end

        # Tip: switch from false to true to enable the re-thrown exception flag
        ::Liquid::Context.new({}, assigns, self.locomotive_default_registers, true)
      end

      # Return the default Liquid assigns used inside the Locomotive Liquid context
      #
      # @return [ Hash ] The default liquid assigns object
      #
      def locomotive_default_assigns
        {
          'site'              => self.site.to_liquid,
          'page'              => self.page,
          'models'            => Locomotive::Builder::Liquid::Drops::ContentTypes.new,
          'contents'          => Locomotive::Builder::Liquid::Drops::ContentTypes.new,
          'current_page'      => self.params[:page],
          'params'            => self.params,
          'path'              => self.request.path,
          'fullpath'          => self.request.fullpath,
          'url'               => self.request.url,
          'now'               => Time.now.utc,
          'today'             => Date.today,
          'locale'            => I18n.locale.to_s,
          'default_locale'    => self.mounting_point.default_locale.to_s,
          'locales'           => self.mounting_point.locales.map(&:to_s),
          'current_user'      => {}
        }
      end

      # Return the default Liquid registers used inside the Locomotive Liquid context
      #
      # @return [ Hash ] The default liquid registers object
      #
      def locomotive_default_registers
        {
          site:           self.site,
          page:           self.page,
          mounting_point: self.mounting_point,
          inline_editor:  false
        }
      end

    end

  end
end