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
      decorated_entity._id = remote_id = remote_entity_id(decorated_entity)

      translated_in(decorated_entity) do |locale|
        if remote_id.nil?
          remote_id = api_client.pages.create(decorated_entity.to_hash)._id
        elsif can_update?(decorated_entity)
          api_client.pages.update(remote_id, decorated_entity.to_hash, locale)
        else
          raise "The local and the remote (#{remote_entity_fullpath_from_handle(decorated_entity)}) versions of that page have the same handle but they are not in the same folder."
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

    def can_update?(local_entity)
      # checking pathes only if the current locale is the default one
      if  local_entity.__locale__.to_s == default_locale.to_s &&
          local_entity.handle &&
          id = remote_entity_id_from_handle(local_entity)
        remote_entity_folder_path(id) == local_entity.folder_path
      else
        true
      end
    end

    def remote_entity_id(local_entity)
      remote_entity_id_from_fullpath(local_entity) || remote_entity_id_from_handle(local_entity)
    end

    def remote_entity_id_from_fullpath(local_entity)
      fullpath = local_entity.fullpath
      remote_entities[fullpath] || remote_entities[fullpath.dasherize]
    end

    def remote_entity_id_from_handle(local_entity)
      remote_entities[local_entity.handle.try(:to_sym)]
    end

    def remote_entity_fullpath_from_handle(local_entity)
      id = remote_entity_id_from_handle(local_entity)
      remote_entities_by_id[id]
    end

    def remote_entities
      return @remote_entities if @remote_entities

      @remote_entities = {}.tap do |hash|
        api_client.pages.fullpaths(default_locale).each do |entity|
          hash[entity.fullpath] = entity._id

          if entity.respond_to?(:handle) && entity.handle.present?
            # to_sym: trick to not have conflicts with fullpaths
            hash[entity.handle.to_sym]  = entity._id
          end
        end
      end
    end

    def remote_entity_folder_path(id)
      if path = remote_entities_by_id[id]
        *segments, slug = path.split('/')
        segments.join('/')
      else
        nil
      end
    end

    def remote_entities_by_id
      @remote_entities_by_id ||= remote_entities.each_with_object({}) do |(key, value), out|
        out[value] = key if key.is_a?(String)
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
      # not deployable?
      return true if entity[:deployable] == false

      # filter enabled?
      return false if @only_entities.blank?

      template_path = entity.template_path[default_locale]

      # no template path (use case: deploying new pages from a different env)
      return true if template_path.nil?

      # not localized?
      return true if template_path == false


      # part of the filter?
      _path = template_path.gsub('./app/views/pages/', '')
      !@only_entities.any? { |regexp| regexp.match(_path) }
    end

  end

end
