require 'tempfile'

module Locomotive::Wagon

  class PushContentAssetsCommand < PushBaseCommand

    def initialize(api_client, steam_services)
      super(api_client, steam_services, nil)
    end

    def decorate(local_path)
      ContentAssetDecorator.new(File.join(path, 'public', local_path))
    end

    def persist(local_path)
      decorated_entity = decorate(local_path)

      if (_entity = remote_entity(decorated_entity)).nil?
        _entity = api_client.content_assets.create(decorated_entity.to_hash)

        # make sure it does not get created a second time if the same file is used in another resource
        remote_entities[decorated_entity.filename] = _entity
      else
        unless same?(decorated_entity, _entity)
          api_client.content_assets.update(_entity._id, decorated_entity.to_hash)
        end
      end

      _entity.url
    end

    private

    def same?(decorated_entity, remote_entity)
      remote_entity.try(:checksum) == decorated_entity.checksum
    end

    def remote_entity(local_entity)
      remote_entities[local_entity.filename]
    end

    def remote_entities
      return @remote_entities if @remote_entities

      @remote_entities = {}.tap do |hash|
        api_client.content_assets.all.each do |entity|
          hash[entity.full_filename] = entity
        end
      end
    end

  end

end
