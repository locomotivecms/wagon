module Locomotive::Wagon

  class PullTranslationsCommand < PullBaseCommand

    def _pull
      translations = api_client.translations.all.inject({}) do |hash, translation|
        translation.values.delete_if { |locale, _| !locales.include?(locale) }
        hash[translation.key] = translation.values
        hash
      end

      unless translations.empty?
        write_translations(translations)
      end
    end

    private

    def write_translations(translations)
      write_to_file(translations_filepath, dump(translations))
    end

    def translations_filepath
      File.join('config', 'translations.yml')
    end

  end

end
