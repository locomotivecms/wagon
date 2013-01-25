module Locomotive
  module Builder
    module Liquid
      module Tags
        # Display the links to change the locale of the current page
        #
        # Usage:
        #
        # {% locale_switcher %} => <div id="locale-switcher"><a href="/features" class="current en">Features</a><a href="/fr/fonctionnalites" class="fr">Fonctionnalités</a></div>
        #
        # {% locale_switcher label: locale, sep: ' - ' }
        #
        # options:
        #   - label: iso (de, fr, en, ...etc), locale (Deutsch, Français, English, ...etc), title (page title)
        #   - sep: piece of html code separating 2 locales
        #
        # notes:
        #   - "iso" is the default choice for label
        #   - " | " is the default separating code
        #
        class LocaleSwitcher < ::Liquid::Tag

          Syntax = /(#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, context)
            @options = { label: 'iso', sep: ' | ' }

            if markup =~ Syntax
              markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

              @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'locale_switcher' - Valid syntax: locale_switcher <options>")
            end

            super
          end

          def render(context)
            @site, @page    = context.registers[:site], context.registers[:page]
            @default_locale = context.registers[:mounting_point].default_locale

            output = %(<div id="locale-switcher">)

            output += @site.locales.collect do |locale|
              Locomotive::Mounter.with_locale(locale) do
                fullpath = localized_fullpath(locale)

                if @page.templatized?
                  permalink = context['entry']._permalink

                  if permalink
                    fullpath.gsub!('*', permalink)
                  else
                    fullpath = '404'
                  end
                end

                css = link_class(locale, context['locale'])

                %(<a href="/#{fullpath}" class="#{css}">#{link_label(locale)}</a>)
              end
            end.join(@options[:sep])

            output += %(</div>)
          end

          private

          def link_class(locale, current_locale)
            css = [locale]
            css << 'current' if locale.to_s == current_locale.to_s
            css.join(' ')
          end

          def link_label(locale)
            case @options[:label]
            when 'iso'     then locale
            when 'locale'  then I18n.t("locomotive.locales.#{locale}", locale: locale)
            when 'title'   then @page.title # FIXME: this returns nil if the page has not been translated in the locale
            else
              locale
            end
          end

          def localized_fullpath(locale)
            # @site.localized_page_fullpath(@page, locale)

            return nil if @page.fullpath_translations.blank?

            fullpath = @page.safe_fullpath || @page.fullpath_or_default

            if locale.to_s == @default_locale.to_s # no need to specify the locale
              @page.index? ? '' : fullpath
            elsif @page.index? # avoid /en/index or /fr/index, prefer /en or /fr instead
              locale
            else
              File.join(locale, fullpath)
            end
          end

        end

        ::Liquid::Template.register_tag('locale_switcher', LocaleSwitcher)
      end
    end
  end
end
# module Locomotive
#   module Builder
#     module Liquid
#       module Tags

#         # Display the links to change the locale of the current page
#         #
#         # Usage:
#         #
#         # {% locale_switcher %} => <div id="locale-switcher"><a href="/features" class="current en">Features</a><a href="/fr/fonctionnalites" class="fr">Fonctionnalités</a></div>
#         #
#         # {% locale_switcher label: locale, sep: ' - ' }
#         #
#         # options:
#         #   - label: iso (de, fr, en, ...etc), locale (Deutsch, Français, English, ...etc), title (page title)
#         #   - sep: piece of html code separating 2 locales
#         #
#         # notes:
#         #   - "iso" is the default choice for label
#         #   - " | " is the default separating code
#         #
#         class LocaleSwitcher < ::Liquid::Tag

#           Syntax = /(#{::Liquid::Expression}+)?/

#           def initialize(tag_name, markup, tokens, context)
#             @options = { label: 'iso', sep: ' | ' }

#             if markup =~ Syntax
#               markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

#               @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]
#             else
#               raise ::Liquid::SyntaxError.new("Syntax Error in 'locale_switcher' - Valid syntax: locale_switcher <options>")
#             end

#             super
#           end

#           def render(context)
#             @site, @page = context.registers[:site], context.registers[:page]

#             output = %(<div id="locale-switcher">)

#             output += @site.locales.collect do |locale|
#               fullpath = locale.to_s == context['default_locale'].to_s ? '/' : locale

#               %(<a href="/#{fullpath}" class="#{locale} #{'current' if locale.to_s == context['default_locale'].to_s}">#{link_label(locale)}</a>)
#             end.join(@options[:sep])

#             output += %(</div>)
#           end

#           private

#           def link_label(locale)
#             case @options[:label]
#             when :iso     then locale
#             when :locale  then I18n.t("locomotive.locales.#{locale}", locale: locale)
#             when :title   then @page.title # FIXME: this returns nil if the page has not been translated in the locale
#             else
#               locale
#             end
#           end

#         end

#         ::Liquid::Template.register_tag('locale_switcher', LocaleSwitcher)
#       end
#     end
#   end
# end