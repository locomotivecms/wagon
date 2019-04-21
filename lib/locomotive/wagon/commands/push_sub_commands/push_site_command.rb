module Locomotive::Wagon

  class PushSiteCommand < PushBaseCommand

    def entities
      [repositories.site.first]
    end

    def decorate(entity)
      UpdateSiteDecorator.new(entity).tap do |decorator|
        decorator.__content_assets_pusher__ = self.content_assets_pusher
      end
    end

    def persist(decorated_entity)
      _attributes = decorated_entity.to_hash

      # push the picture only if there is no existing remote picture
      _attributes.delete(:picture) if remote_site['picture_url'].present?

      # push the locales as long as there is no content on the remote site yet
      _attributes.delete(:locales) if remote_site.edited?

      _attributes.delete(:metafields) unless with_data?

      _attributes.delete(:sections_content) unless with_data?

      if _attributes.present?
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
