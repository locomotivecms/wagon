module Locomotive
  module Wagon
    module Liquid
      module Tags
        class LinkTo < Hybrid

          Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/

          include PathHelper

          def initialize(tag_name, markup, tokens, options)
            if markup =~ Syntax
              @handle = $1
              @_options = {}
              markup.scan(::Liquid::TagAttributes) do |key, value|
                @_options[key] = value
              end
            else
              raise ::Liquid::SyntaxError.new(options[:locale].t("errors.syntax.link_to"), options[:line])
            end

            super
          end

          def render(context)
            render_path(context) do |page, path|
              label = label_from_page(page)

              if @render_as_block
                context.scopes.last['target'] = page
                label = super.html_safe
              end

              if @_options['class']
                css_classes = @_options['class'].gsub("'", '')
                class_attr = " class=\"#{css_classes}\""
              else
                class_attr = ''
              end

              %{<a href="#{path}"#{class_attr}>#{label}</a>}
            end
          end

          protected

          def label_from_page(page)
            ::Locomotive::Mounter.with_locale(@_options['locale']) do
              if page.templatized?
                page.content_entry._label
              else
                page.title
              end
            end
          end

        end

        ::Liquid::Template.register_tag('link_to', LinkTo)
      end
    end
  end
end