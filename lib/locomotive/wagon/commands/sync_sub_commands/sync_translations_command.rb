module Locomotive::Wagon

  class SyncTranslationsCommand < PullTranslationsCommand

    include Locomotive::Wagon::BaseConcern

    private

    def write_translations(translations)
      write_to_file(translations_filepath, JSON.neat_generate(translations, {
        sort: true, short: false, padding: 1, object_padding: 1, after_colon: 1, after_comma: 1, wrap: 20, aligned: false
      }))
    end

    def translations_filepath
      File.join('data', env.to_s, 'translations.json')
    end

  end

end
