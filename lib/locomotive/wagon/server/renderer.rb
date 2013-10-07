module Locomotive::Wagon
  class Server

    class Renderer < Middleware

      def call(env)
        self.set_accessors(env)

        if self.page
          if self.page.redirect?
            self.redirect_to(self.page.redirect_url, self.page.redirect_type)
          else
            type = self.page.response_type || 'text/html'
            html = self.render_page

            self.log "  Rendered liquid page template"

            [200, { 'Content-Type' => type }, [html]]
          end
        else
          # no page at all, even not the 404 page
          [404, { 'Content-Type' => 'text/html' }, ['Page not found']]
        end
      end

      protected

      def render_page
        context = self.locomotive_context
        begin
          self.page.render(context)
        rescue Exception => e
          raise RendererException.new(e, self.page.title, self.page.template, context)
        end
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

        # assigns from other middlewares
        assigns.merge!(self.liquid_assigns)

        assigns.merge!(other_assigns)

        # templatized page
        if self.page && self.content_entry
          ['content_entry', 'entry', self.page.content_type.slug.singularize].each do |key|
            assigns[key] = self.content_entry
          end
        end

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
          'models'            => Locomotive::Wagon::Liquid::Drops::ContentTypes.new,
          'contents'          => Locomotive::Wagon::Liquid::Drops::ContentTypes.new,
          'current_page'      => self.params[:page],
          'params'            => self.params.stringify_keys,
          'path'              => self.request.path,
          'fullpath'          => self.request.fullpath,
          'url'               => self.request.url,
          'ip_address'        => self.request.ip,
          'post?'             => self.request.post?,
          'host'              => self.request.host_with_port,
          'now'               => Time.zone.now,
          'today'             => Date.today,
          'locale'            => I18n.locale.to_s,
          'default_locale'    => self.mounting_point.default_locale.to_s,
          'locales'           => self.mounting_point.locales.map(&:to_s),
          'current_user'      => {},
          'session'           => Locomotive::Wagon::Liquid::Drops::SessionProxy.new,
          'wagon'             => true
        }
      end

      # Return the default Liquid registers used inside the Locomotive Liquid context
      #
      # @return [ Hash ] The default liquid registers object
      #
      def locomotive_default_registers
        {
          request:        self.request,
          site:           self.site,
          page:           self.page,
          mounting_point: self.mounting_point,
          inline_editor:  false,
          logger:         Locomotive::Wagon::Logger
        }
      end

    end

  end
end