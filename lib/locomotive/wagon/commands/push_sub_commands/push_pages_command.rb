module Locomotive::Wagon

  class PushPagesCommand < PushBaseCommand

    def entities
      repositories.page.all
    end

    def decorate(entity)
      # puts entity.inspect
      PageDecorator.new(entity, locale, default_locale)
    end

    def persist(decorated_entity)
      # puts decorated_entity.to_hash
      # api_client.snippets.update(decorated_entity.slug, decorated_entity.to_hash)
    end

    def label_for(decorated_entity)
      decorated_entity.fullpath
    end

  end

end
