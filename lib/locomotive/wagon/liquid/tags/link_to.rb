module Locomotive
  module Wagon
    module Liquid
      module Tags
        class LinkTo < Hybrid

          Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @handle = $1
              @options = {}
              markup.scan(::Liquid::TagAttributes) do |key, value|
                @options[key] = value
              end
            else
              raise SyntaxError.new("Syntax Error in 'link_to' - Valid syntax: link_to page_handle, locale es (locale is optional)")
            end

            super
          end

          def render(context)
            if page = self.retrieve_page_from_handle(context)
              label = self.label_from_page(page)
              path  = self.public_page_url(context, page)

              if @render_as_block
                context.scopes.last['target'] = page
                label = super.html_safe
              end

              %{<a href="#{path}">#{label}</a>}
            else
              raise Liquid::PageNotTranslated.new(%{[link_to] Unable to find a page for the #{@handle}. Wrong handle or missing template for your content.})
            end
          end

          protected

          def retrieve_page_from_handle(context)
            mounting_point = context.registers[:mounting_point]

            context.scopes.reverse_each do |scope|
              handle = scope[@handle] || @handle

              page = case handle
              when Locomotive::Mounter::Models::Page          then handle
              when String                                     then fetch_page(mounting_point, handle)
              when Liquid::Drops::ContentEntry                then fetch_page(mounting_point, handle._source, true)
              when Locomotive::Mounter::Models::ContentEntry  then fetch_page(mounting_point, handle, true)
              else
                nil
              end

              return page unless page.nil?
            end

            nil
          end

          def fetch_page(mounting_point, handle, templatized = false)
            ::Locomotive::Mounter.with_locale(@options['locale']) do
              if templatized
                page = mounting_point.pages.values.find do |_page|
                  _page.templatized? &&
                  _page.content_type.slug == handle.content_type.slug &&
                  (@options['with'].nil? || _page.handle == @options['with'])
                end

                page.content_entry = handle if page

                page
              else
                mounting_point.pages.values.find { |_page| _page.handle == handle }
              end
            end
          end

          def label_from_page(page)
            ::Locomotive::Mounter.with_locale(@options['locale']) do
              if page.templatized?
                page.content_entry._label
              else
                page.title
              end
            end
          end

          def public_page_url(context, page)
            mounting_point  = context.registers[:mounting_point]
            locale          = @options['locale'] || ::I18n.locale

            if !page.translated_in?(locale)
              title = page.title_translations.values.compact.first
              raise Liquid::PageNotTranslated.new(%{the "#{title}" page is not translated in #{locale.upcase}})
            end

            fullpath = ::Locomotive::Mounter.with_locale(locale) do
              page.fullpath.clone
            end

            fullpath = "#{::I18n.locale}/#{fullpath}" if ::I18n.locale.to_s != mounting_point.default_locale.to_s

            if page.templatized?
              fullpath.gsub!(/(content[_-]type[_-]template|template)/, page.content_entry._slug) unless page.content_entry._slug.nil?
            end

            File.join('/', fullpath)
          end

        end

        ::Liquid::Template.register_tag('link_to', LinkTo)
      end
    end
  end
end