module Locomotive::Wagon

  class PushSiteCommand < PushBaseCommand

    def entities
      [repositories.site.first]
    end

    def decorate(entity)
      IconSiteDecorator.new(entity)
    end

    def persist(decorated_entity)
      _attributes = decorated_entity.to_hash

      if !_attributes.empty? && api_client.current_site.get.attributes[:picture_url].nil?
        api_client.current_site.update(_attributes)
      else
        raise SkipPersistingException.new
      end
    end

    def label_for(decorated_entity)
      decorated_entity.name
    end

  end

end
