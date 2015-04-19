module Locomotive::Wagon

  class PushSnippetsCommand < PushBaseCommand

    def entities
      repositories.snippet.all
    end

    def decorate(entity)
      SnippetDecorator.new(entity, locale, default_locale)
    end

    def persist(decorated_entity)
      api_client.snippets.update(decorated_entity.slug, decorated_entity.to_hash)
    end

    def label_for(decorated_entity)
      decorated_entity.name
    end

  end

end
