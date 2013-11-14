module Locomotive
  module Wagon
    module Liquid
      module Tags

        module UrlHelper

          def render_url(context, &block)
            site  = context.registers[:site]

            if page = self.retrieve_page_from_handle(context)
              url = self.public_page_url(context, page)

              if block_given?
                block.call page, url
              else
                url
              end
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
              when Liquid::Drops::Page                        then handle.instance_variable_get(:@_source)
              when String                                     then fetch_page(mounting_point, handle)
              when Liquid::Drops::ContentEntry                then fetch_page(mounting_point, handle.instance_variable_get(:@_source), true)
              when Locomotive::Mounter::Models::ContentEntry  then fetch_page(mounting_point, handle, true)
              else
                nil
              end

              return page unless page.nil?
            end

            nil
          end

          def fetch_page(mounting_point, handle, templatized = false)
            ::Locomotive::Mounter.with_locale(@_options['locale']) do
              if templatized
                page = mounting_point.pages.values.find do |_page|
                  _page.templatized? &&
                  !_page.templatized_from_parent &&
                  _page.content_type.slug == handle.content_type.slug &&
                  (@_options['with'].nil? || _page.handle == @_options['with'])
                end

                page.content_entry = handle if page

                page
              else
                mounting_point.pages.values.find { |_page| _page.handle == handle }
              end
            end
          end

          def public_page_url(context, page)
            mounting_point  = context.registers[:mounting_point]
            locale          = @_options['locale'] || ::I18n.locale

            if !page.translated_in?(locale)
              title = page.title_translations.values.compact.first
              raise Liquid::PageNotTranslated.new(%{the "#{title}" page is not translated in #{locale.upcase}})
            end

            fullpath = ::Locomotive::Mounter.with_locale(locale) do
              page.fullpath.clone
            end

            fullpath = "#{::I18n.locale}/#{fullpath}" if ::I18n.locale.to_s != mounting_point.default_locale.to_s

            if page.templatized?
              if page.content_entry._slug.nil?
                title = %{#{page.content_entry.content_type.name.singularize} "#{page.content_entry.send(page.content_entry.content_type.label_field_name)}"}
                raise Liquid::ContentEntryNotTranslated.new(%{the #{title} slug is not translated in #{locale.upcase}})
              end
              fullpath.gsub!(/(content[_-]type[_-]template|template)/, page.content_entry._slug)
            end

            File.join('/', fullpath)
          end

        end
      end

    end
  end
end