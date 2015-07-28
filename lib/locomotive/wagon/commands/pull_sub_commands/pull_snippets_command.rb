module Locomotive::Wagon

  class PullSnippetsCommand < PullBaseCommand

    def _pull
      locales.each do |locale|
        api_client.snippets.all(locale).each do |snippet|
          write_snippet(snippet, locale)
        end
      end
    end

    def write_snippet(snippet, locale = nil)
      if (template = snippet.template).present?
        _template = replace_asset_urls(template)
        write_to_file(snippet_filepath(snippet, locale), _template)
      end
    end

    private

    def snippet_filepath(snippet, locale)
      filename = locale == default_locale ? snippet.slug : "#{snippet.slug}.#{locale}"
      File.join('app', 'views', 'snippets', filename + '.liquid')
    end

  end

end
