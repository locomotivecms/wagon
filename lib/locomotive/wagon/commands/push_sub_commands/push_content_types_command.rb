module Locomotive::Wagon

  class PushContentTypesCommand < PushBaseCommand

    attr_reader :step

    alias_method :default_push, :_push

    def _push
      %i(without_relationships only_relationships).each do |step|
        @step = step
        default_push
      end
    end

    def entities
      repositories.content_type.all
    end

    def decorate(entity)
      if without_relationships?
        ContentTypeDecorator.new(entity, remote_fields_for(entity.slug))
      else
        ContentTypeWithOnlyRelationshipsDecorator.new(entity)
      end
    end

    def persist(decorated_entity)
      raise SkipPersistingException.new if only_relationships? && !decorated_entity.with_relationships?

      api_client.content_types.update(decorated_entity.slug, decorated_entity.to_hash)
    end

    def label_for(decorated_entity)
      name = decorated_entity.name

      if without_relationships?
        name
      else
        "#{name} with relationships"
      end
    end

    private

    def remote_fields_for(slug)
      (remote_entities[slug].try(:fields) || []).map { |f| f['name'] }
    end

    def remote_entities
      return @remote_entities if @remote_entities

      @remote_entities = {}.tap do |hash|
        api_client.content_types.all.each do |entity|
          hash[entity.slug] = entity
        end
      end
    end

    def without_relationships?
      self.step == :without_relationships
    end

    def only_relationships?
      self.step == :only_relationships
    end

  end

end
