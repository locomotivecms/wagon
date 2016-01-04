module Locomotive::Wagon

  class PushPagesCommand < PushBaseCommand

    def entities
      repositories.page.all.map do |entity|
        next if skip?(entity)
        entity
      end.compact
    end

    def decorate(entity)
      _decorate(entity).tap do |decorated|
        if parent = repositories.page.parent_of(entity)
          decorated[:parent] = _decorate(parent).fullpath
        end
      end
    end

    def persist(decorated_entity)
      decorated_entity._id = remote_id = remote_entity_id(decorated_entity.fullpath)

      translated_in(decorated_entity) do |locale|
        if remote_id.nil?
          remote_id = api_client.pages.create(decorated_entity.to_hash)._id
        else
          api_client.pages.update(remote_id, decorated_entity.to_hash, locale)
        end
      end
    end

    def label_for(decorated_entity)
      _locales = translated_in(decorated_entity).join(', ')

      if _locales.blank?
        decorated_entity.fullpath
      else
        decorated_entity.fullpath + " (#{_locales})"
      end
    end

    private

    def _decorate(entity)
      persist_content = with_data? || !remote_site.edited?
      PageDecorator.new(entity, default_locale, content_assets_pusher, persist_content)
    end

    def remote_entity_id(fullpath)
      remote_entities[fullpath] || remote_entities[fullpath.dasherize]
    end

    def remote_entities
      return @remote_entities if @remote_entities

      @remote_entities = {}.tap do |hash|
        api_client.pages.fullpaths(default_locale).each do |entity|
          hash[entity.fullpath] = entity._id
        end
      end
    end

    def translated_in(decorated_entity, &block)
      locales.find_all do |locale|
        decorated_entity.__with_locale__(locale) do
          decorated_entity.slug.present?.tap do |present|
            yield(locale) if block_given? && present
          end
        end
      end
    end

    def skip?(entity)
      return false if @only_entities.blank?

      _path = entity.template_path[default_locale].gsub('./app/views/pages/', '')

      !@only_entities.any? { |regexp| regexp.match(_path) }
    end

  end

end
