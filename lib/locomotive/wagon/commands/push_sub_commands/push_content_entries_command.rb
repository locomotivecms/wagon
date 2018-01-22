module Locomotive::Wagon

  class PushContentEntriesCommand < PushBaseCommand

    attr_reader :step

    alias_method :default_push, :_push

    def _push
      ([:without_relationships] + other_locales + [:only_relationships]).each do |step|
        @step = step
        default_push
      end
    end

    def entities
      @entities ||= repositories.content_type.all.map do |content_type|
        # bypass a locale if there is no fields marked as localized
        next if skip_content_type?(content_type) || (locale? && content_type.fields.localized_names.blank?)

        repositories.content_entry.with(content_type).all(_visible: nil)
      end.compact.flatten
    end

    def decorate(entity)
      if locale?
        ContentEntryWithLocalizedAttributesDecorator.new(entity, @step, path, content_assets_pusher)
      elsif only_relationships?
        ContentEntryWithOnlyRelationshipsDecorator.new(entity, default_locale, path, content_assets_pusher)
      else
        ContentEntryDecorator.new(entity, default_locale, path, content_assets_pusher)
      end
    end

    def persist(decorated_entity)
      attributes = decorated_entity.to_hash

      raise SkipPersistingException.new if attributes.blank?

      _locale = locale? ? @step : nil

      remote_entity = api_client.content_entries(decorated_entity.content_type).update(decorated_entity._id, attributes, _locale)

      # Note: very important to use the real id in the next API calls
      # because the _slug can be localized and so, won't be unique for
      # a content entry.
      decorated_entity._id = remote_entity._id
    end

    def label_for(decorated_entity)
      label = decorated_entity.__with_locale__(default_locale) { decorated_entity._label }
      label = "#{decorated_entity.content_type.name} / #{label}"

      if without_relationships?
        label
      elsif only_relationships?
        "#{label} with relationships"
      elsif locale?
        "#{label} in #{self.step}"
      end
    end

    private

    def other_locales
      return [] if current_site.locales.blank?
      current_site.locales - [current_site.default_locale]
    end

    def without_relationships?
      self.step == :without_relationships
    end

    def only_relationships?
      self.step == :only_relationships
    end

    def locale?
      other_locales.include?(self.step)
    end

    def skip_content_type?(content_type)
      return false if @only_entities.blank?

      slug = content_type.slug

      !@only_entities.any? { |regexp| regexp.match(slug) }
    end

  end

end

