module Locomotive
  module Wagon
    module Liquid
      module Tags

        # Display the children pages of the site, current page or the parent page. If not precised, nav is applied on the current page.
        # The html output is based on the ul/li tags.
        #
        # Usage:
        #
        # {% nav site %} => <ul class="nav"><li class="on"><a href="/features">Features</a></li></ul>
        #
        # {% nav site, no_wrapper: true, exclude: 'contact|about', id: 'main-nav', class: 'nav', active_class: 'on' }
        #
        class Nav < ::Liquid::Tag

          Syntax = /(#{::Liquid::Expression}+)?/

          attr_accessor :current_page, :mounting_point

          def initialize(tag_name, markup, tokens, options)
            if markup =~ Syntax
              @source = ($1 || 'page').gsub(/"|'/, '')

              self.set_options(markup, options)
            else
              raise ::Liquid::SyntaxError.new(options[:locale].t("errors.syntax.nav"), options[:line])
            end

            super
          end

          def render(context)
            self.set_accessors_from_context(context)

            entries = self.fetch_entries
            output  = self.build_entries_output(entries)

            if self.no_wrapper?
              output
            else
              self.render_tag(:nav, id: @_options[:id], css: @_options[:class]) do
                self.render_tag(:ul) { output }
              end
            end
          end

          protected

          # Build recursively the links of all the pages.
          #
          # @param [ Array ] entries List of pages
          #
          # @return [ String ] The final HTML output
          #
          def build_entries_output(entries, depth = 1)
            output  = []

            entries.each_with_index do |page, index|
              css = []
              css << 'first'  if index == 0
              css << 'last'   if index == entries.size - 1

              output << self.render_entry_link(page, css.join(' '), depth)
            end

            output.join("\n")
          end

          # Get all the children of a source: site (index page), parent or page.
          #
          # @return [ Array ] List of pages
          #
          def fetch_entries
            children = (case @source
            when 'site'     then self.mounting_point.pages['index']
            when 'parent'   then self.current_page.parent || self.current_page
            when 'page'     then self.current_page
            else
              self.mounting_point.pages[@source]
            end).children.try(:clone) || []

            children.delete_if { |p| !include_page?(p) }
          end

          # Determine whether or not a page should be a part of the menu.
          #
          # @param [ Object ] page The page
          #
          # @return [ Boolean ] True if the page can be included or not
          #
          def include_page?(page)
            if !page.listed? || page.templatized? || !page.published?
              false
            elsif @_options[:exclude]
              (page.fullpath =~ @_options[:exclude]).nil?
            else
              true
            end
          end

          # Determine wether or not a page is currently the displayed one.
          #
          # @param [ Object ] page The page
          #
          # @return [ Boolean ]
          #
          def page_selected?(page)
            self.current_page.fullpath =~ /^#{page.fullpath}(\/.*)?$/
          end

          # Determine if the children of a page have to be rendered or not.
          # It depends on the depth passed in the option.
          #
          # @param [ Object ] page The page
          # @param [ Integer ] depth The current depth
          #
          # @return [ Boolean ] True if the children have to be rendered.
          #
          def render_children_for_page?(page, depth)
            depth.succ <= @_options[:depth].to_i &&
            (page.children || []).select { |child| self.include_page?(child) }.any?
          end

          # Return the label of an entry. It may use or not the template
          # given by the snippet option.
          #
          # @param [ Object ] page The page
          #
          # @return [ String ] The label in HTML
          #
          def entry_label(page)
            icon  = @_options[:icon] ? '<span></span>' : ''
            title = @_options[:liquid_render] ? @_options[:liquid_render].render('page' => page) : page.title

            if icon.blank?
              title
            elsif @_options[:icon] == 'after'
              "#{title} #{icon}"
            else
              "#{icon} #{title}"
            end
          end

          # Return the localized url of an entry (page).
          #
          # @param [ Object ] page The page
          #
          # @return [ String ] The localized url
          #
          def entry_url(page)
            if ::I18n.locale.to_s == self.mounting_point.default_locale.to_s && !@_options[:force_locale]
              "/#{page.fullpath}"
            else
              "/#{::I18n.locale}/#{page.fullpath}"
            end
          end

          # Return the css of an entry (page).
          #
          # @param [ Object ] page The page
          # @param [ String ] css The extra css
          #
          # @return [ String ] The css
          #
          def entry_css(page, css = '')
            _css = 'link'
            _css += " #{page} #{@_options[:active_class]}" if self.page_selected?(page)

            (_css + " #{css}").strip
          end

          # Return the HTML output of a page and its children if requested.
          #
          # @param [ Object ] page The page
          # @param [ String ] css The current css to apply to the entry
          # @param [ Integer] depth Used to know if the children has to be added or not.
          #
          # @return [ String ] The HTML output
          #
          def render_entry_link(page, css, depth)
            url       = self.entry_url(page)
            label     = self.entry_label(page)
            css       = self.entry_css(page, css)
            options   = ''

            if self.render_children_for_page?(page, depth) && self.bootstrap?
              url       = '#'
              label     += %{ <b class="caret"></b>}
              css       += ' dropdown'
              options   = %{ class="dropdown-toggle" data-toggle="dropdown"}
            end

            self.render_tag(:li, id: "#{page.slug.to_s.dasherize}-link", css: css) do
              children_output = depth.succ <= @_options[:depth].to_i ? self.render_entry_children(page, depth.succ) : ''
              %{<a href="#{url}"#{options}>#{label}</a>} + children_output
            end
          end

          # Recursively create a nested unordered list for the depth specified.
          #
          # @param [ Array ] entries The children of the page
          # @param [ Integer ] depth The current depth
          #
          # @return [ String ] The HTML code
          #
          def render_entry_children(page, depth)
            entries = (page.children || []).select { |child| self.include_page?(child) }
            css     = self.bootstrap? ? 'dropdown-menu' : ''

            unless entries.empty?
              self.render_tag(:ul, id: "#{@_options[:id]}-#{page.slug.to_s.dasherize}", css: css) do
                self.build_entries_output(entries, depth)
              end
            else
              ''
            end
          end

          # Set the value (default or assigned by the tag) of the options.
          #
          def set_options(markup, options)
            @_options = { id: 'nav', class: '', active_class: 'on', bootstrap: false, no_wrapper: false }

            markup.scan(::Liquid::TagAttributes) { |key, value| @_options[key.to_sym] = value.gsub(/"|'/, '') }

            @_options[:exclude] = Regexp.new(@_options[:exclude]) if @_options[:exclude]

            if @_options[:snippet]
              if template = self.parse_snippet_template(options, @_options[:snippet])
                @_options[:liquid_render] = template
              end
            end
          end

          # Avoid to call context.registers to get the current page
          # and the mounting point.
          #
          def set_accessors_from_context(context)
            self.current_page   = context.registers[:page]
            self.mounting_point = context.registers[:mounting_point]
          end

          # Parse the template of the snippet give in option of the tag.
          # If the template_name contains a liquid tag or drop, it will
          # be used an inline template.
          #
          def parse_snippet_template(context, template_name)
            source = if template_name.include?('{')
              template_name
            else
              context[:mounting_point].snippets[template_name].try(:source)
            end

            source ? ::Liquid::Template.parse(source) : nil
          end

          # Render any kind HTML tags. The content of the tag comes from
          # the block.
          #
          # @param [ String ] tag_name Name of the HTML tag (li, ul, div, ...etc).
          # @param [ String ] html_options Id, class, ..etc
          #
          # @return [ String ] The HTML
          #
          def render_tag(tag_name, html_options = {}, &block)
            options = ['']
            options << %{id="#{html_options[:id]}"} if html_options[:id].present?
            options << %{class="#{html_options[:css]}"} if html_options[:css].present?

            %{<#{tag_name}#{options.join(' ')}>#{yield}</#{tag_name}>}
          end

          def bootstrap?
            @_options[:bootstrap].to_bool
          end

          def no_wrapper?
            @_options[:no_wrapper].to_bool
          end

          ::Liquid::Template.register_tag('nav', Nav)
        end
      end
    end
  end
end