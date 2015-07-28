module Locomotive::Wagon

  class PullTranslationsCommand < PullBaseCommand

    def _pull
      translations = api_client.translations.all.inject({}) do |hash, translation|
        hash[translation.key] = translation.values
        hash
      end

      unless translations.empty?
        write_to_file(translations_filepath, dump(translations))
      end
    end

    private

    def translations_filepath
      File.join('config', 'translations.yml')
    end

  end

end
