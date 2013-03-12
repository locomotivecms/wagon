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

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @source = ($1 || 'page').gsub(/"|'/, '')
              @options = { :id => 'nav', :class => '', :active_class => 'on', :bootstrap => false }
              markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

              @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]

              if @options[:snippet]
                if template = self.parse_snippet_template(context, @options[:snippet])
                  @options[:liquid_render] = template
                end
              end
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'nav' - Valid syntax: nav <site|parent|page|<path to a page>> <options>")
            end

            super
          end

          def render(context)
            self.set_accessors_from_context(context)

            children_output = []

            entries = self.fetch_entries

            entries.each_with_index do |p, index|
              css = []
              css << 'first' if index == 0
              css << 'last' if index == entries.size - 1

              children_output << render_entry_link(p, css.join(' '), 1)
            end

            output = children_output.join("\n")

            if @options[:no_wrapper] != 'true'
              output = %{<ul id="#{@options[:id]}" class="#{@options[:class]}">\n#{output}</ul>}
            end

            output
          end

          protected

          def set_accessors_from_context(context)
            self.current_page   = context.registers[:page]
            self.mounting_point = context.registers[:mounting_point]
          end

          def parse_snippet_template(context, template_name)
            source = if template_name.include?('{')
              template_name
            else
              context[:mounting_point].snippets[template_name].try(:source)
            end

            source ? ::Liquid::Template.parse(source) : nil
          end

          def fetch_entries
            children = (case @source
            when 'site'     then self.mounting_point.pages['index']
            when 'parent'   then self.current_page.parent || self.current_page
            when 'page'     then self.current_page
            else
              self.mounting_point.pages[@source]
            end).children.clone

            children.delete_if { |p| !include_page?(p) }
          end

          # Determines whether or not a page should be a part of the menu
          def include_page?(page)
            if !page.listed? || page.templatized? || !page.published?
              false
            elsif @options[:exclude]
              (page.fullpath =~ @options[:exclude]).nil?
            else
              true
            end
          end

          # Returns a list element, a link to the page and its children
          def render_entry_link(page, css, depth)
            selected = self.current_page.fullpath =~ /^#{page.fullpath}/ ? " #{@options[:active_class]}" : ''

            icon = @options[:icon] ? '<span></span>' : ''

            title = @options[:liquid_render] ? @options[:liquid_render].render('page' => page) : page.title

            label = %{#{icon if @options[:icon] != 'after' }#{title}#{icon if @options[:icon] == 'after' }}

            dropdow = ""
            link_options = ""
            href = ::I18n.locale.to_s == self.mounting_point.default_locale.to_s ? "/#{page.fullpath}" : "/#{::I18n.locale}/#{page.fullpath}"
            caret = ""

            if render_children_for_page?(page, depth) && bootstrap?
              dropdow = "dropdown"
              link_options = %{class="dropdown-toggle" data-toggle="dropdown"}
              href = "#"
              caret = %{<b class="caret"></b>}
            end

            output  = %{<li id="#{page.slug.to_s.dasherize}-link" class="link#{selected} #{css} #{dropdow}">}
            output << %{<a href="#{href}" #{link_options}>#{label} #{caret}</a>}
            output << render_entry_children(page, depth.succ) if (depth.succ <= @options[:depth].to_i)
            output << %{</li>}

            output.strip
          end

          def render_children_for_page?(page, depth)
            depth.succ <= @options[:depth].to_i && page.children.reject { |c| !include_page?(c) }.any?
          end

          # Recursively creates a nested unordered list for the depth specified
          def render_entry_children(page, depth)
            output = %{}

            children = page.children.reject { |c| !include_page?(c) }
            if children.present?
              output = %{<ul id="#{@options[:id]}-#{page.slug.to_s.dasherize}" class="#{bootstrap? ? "dropdown-menu" : ""}">}
              children.each do |c, page|
                css = []
                css << 'first' if children.first == c
                css << 'last'  if children.last  == c

                output << render_entry_link(c, css.join(' '),depth)
              end
              output << %{</ul>}
            end

            output
          end

          def bootstrap?
            @options[:bootstrap] == 'true' || @options[:bootstrap] == true
          end

          ::Liquid::Template.register_tag('nav', Nav)
        end
      end
    end
  end
end