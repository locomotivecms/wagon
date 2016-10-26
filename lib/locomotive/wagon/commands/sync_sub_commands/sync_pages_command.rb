module Locomotive::Wagon

  class SyncPagesCommand < PullPagesCommand

    include Locomotive::Wagon::BaseConcern

    def write_page(page, locale = nil)
      filepath = page_filepath(page, locale)

      if File.exists?(filepath)
        # only copy the content of the editable elements
        if attributes = editable_elements_attributes(page, locale)
          new_content = replace_editable_elements(filepath, dump(attributes))

          write_to_file(filepath, new_content)
        end
      else
        # pull the whole page
        super
      end
    end

    private

    def editable_elements_attributes(page, locale)
      list = page.editable_elements.inject({}) do |hash, el|
        hash["#{el['block']}/#{el['slug']}"] = replace_asset_urls(el['content']) if el['content']
        hash
      end

      list.empty? ? nil : { 'editable_elements' => list }
    end

    def replace_editable_elements(filepath, replacement)
      content   = File.read(File.join(path, filepath), encoding: 'utf-8')
      existing  = content =~ /\A.*?editable_elements:.*?\n---/m

      content.gsub /\A---(.*?)\n---/m do |s|
        if existing
          s.gsub(/editable_elements:\n(.*?)\n(\S)/m) { |_s| "#{replacement}#{$2}" }
        else
          s.gsub(/---\Z/) { |_s| "#{replacement}\n---" }
        end
      end
    end

    def page_filepath(page, locale)
      fullpath = locale == default_locale ? page.fullpath : "#{fullpaths[page._id]}.#{locale}"

      # HAML template?
      if File.exists?(filepath = _page_filepath(fullpath, '.haml'))
        return filepath
      end

      # simple Liquid template OR the page does not exist in the local site
      _page_filepath(fullpath)
    end

    def _page_filepath(fullpath, additional_extension = '')
      File.join('app', 'views', 'pages', fullpath + ".liquid#{additional_extension}")
    end

  end

end
