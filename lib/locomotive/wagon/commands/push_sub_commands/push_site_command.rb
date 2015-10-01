module Locomotive::Wagon

  class PushSiteCommand < PushBaseCommand

    def entities
      [repositories.site.first]
    end

    def decorate(entity)
      UpdateSiteDecorator.new(entity)
    end

    def persist(decorated_entity)
      _attributes = decorated_entity.to_hash

      # push the picture only if there is no existing remote picture
      _attributes.delete(:picture) if remote_entity['picture_url'].present?

      # push the locales as long as there is no content on the remote site yet
      _attributes.delete(:locales) if remote_entity['content_version'].to_i > 0

      if _attributes.present?
        api_client.current_site.update(_attributes)
      else
        raise SkipPersistingException.new
      end
    end

    def label_for(decorated_entity)
      decorated_entity.name
    end

    def remote_entity
      @remote_entity ||= api_client.current_site.get.attributes
    end

  end

end
