module Locomotive::Wagon

  class PushTranslationsCommand < PushBaseCommand

    def entities
      repositories.translation.all
    end

    def decorate(entity)
      TranslationDecorator.new(entity)
    end

    def persist(decorated_entity)
      api_client.translations.update(decorated_entity.id, decorated_entity.to_hash)
    end

    def label_for(decorated_entity)
      decorated_entity.key
    end

  end

end
