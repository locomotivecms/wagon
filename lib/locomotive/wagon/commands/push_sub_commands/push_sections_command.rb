module Locomotive::Wagon

  class PushSectionsCommand < PushBaseCommand

    def entities
      repositories.section.all
    end

    def decorate(entity)
      SectionDecorator.new(entity, content_assets_pusher)
    end

    def persist(decorated_entity)
      api_client.sections.update(decorated_entity.slug, decorated_entity.to_hash)
    end

    def label_for(decorated_entity)
      decorated_entity.name
    end

  end

end
