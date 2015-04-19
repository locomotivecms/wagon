require 'tempfile'

module Locomotive::Wagon

  class PushThemeAssetsCommand < PushBaseCommand

    def entities
      repositories.theme_asset.all.map do |entity|
        decorated = ThemeAssetDecorator.new(entity)
      end.sort { |a, b| a.priority <=> b.priority }
    end

    def decorate(entity)
      entity # already decorated
    end

    def persist(decorated_entity)
      precompile(decorated_entity)

      if (_entity = remote_entity(decorated_entity)).nil?
        api_client.theme_assets.create(decorated_entity.to_hash)
      else
        raise SkipPersistingException.new if same?(decorated_entity, _entity)

        api_client.theme_assets.update(_entity._id, decorated_entity.to_hash)
      end
    end

    def label_for(decorated_entity)
      decorated_entity.relative_url
    end

    private

    def precompile(entity)
      return unless entity.stylesheet_or_javascript?

      Tempfile.new(entity.realname).tap do |file|
        env = Locomotive::Steam::SprocketsEnvironment.new(File.join(path, 'public'), minify: true)

        file.write(env[entity.short_relative_url].to_s)

        entity.filepath = file.path

        file.close
      end
    end

    def same?(decorated_entity, remote_entity)
      remote_entity.try(:checksum) == decorated_entity.checksum
    end

    def remote_entity(local_entity)
      remote_entities[local_entity.relative_url]
    end

    def remote_entities
      return @remote_entities if @remote_entities

      @remote_entities = {}.tap do |hash|
        api_client.theme_assets.all.each do |entity|
          relative_url = "#{entity.folder}/#{entity.local_path}"
          hash[relative_url] = entity
        end
      end
    end

  end

end
