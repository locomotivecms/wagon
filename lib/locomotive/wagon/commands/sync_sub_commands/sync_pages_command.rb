module Locomotive::Wagon

  class SyncPagesCommand < SyncBaseCommand

    attr_reader :fullpaths

    def _sync
      @fullpaths = {}

      locales.each do |locale|
        api_client.pages.all(locale).each do |page|
          fullpaths[page._id] = page.fullpath if locale == default_locale
          write_page(page, locale)
        end
      end
    end

    def write_page(page, locale = nil)
      if attributes = editable_elements_attributes(page, locale)
        new_content = replace_editable_elements(page_filepath(page, locale), dump(attributes))

        write_to_file(page_filepath(page, locale), new_content)
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
      content   = File.read(File.join(path, filepath))
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
      File.join('app', 'views', 'pages', fullpath + '.liquid')
    end

  end

end
