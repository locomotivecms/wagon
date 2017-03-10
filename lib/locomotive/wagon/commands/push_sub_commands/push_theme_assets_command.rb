require 'tempfile'

module Locomotive::Wagon

  class PushThemeAssetsCommand < PushBaseCommand

    def entities
      repositories.theme_asset.all.map do |entity|
        next if skip?(entity)
        decorated = ThemeAssetDecorator.new(entity)
      end.compact.sort { |a, b| a.priority <=> b.priority }
    end

    def decorate(entity)
      entity # already decorated
    end

    def persist(decorated_entity)
      return if decorated_entity.realname.starts_with?('_')

      precompile(decorated_entity)

      resource = if (_entity = remote_entity(decorated_entity)).nil?
        api_client.theme_assets.create(decorated_entity.to_hash)
      else
        raise SkipPersistingException.new if same?(decorated_entity, _entity)
        api_client.theme_assets.update(_entity._id, decorated_entity.to_hash)
      end

      register_url(resource)
    end

    def label_for(decorated_entity)
      decorated_entity.relative_url
    end

    private

    def precompile(entity)
      return unless entity.stylesheet_or_javascript?

      Tempfile.new(entity.realname).tap do |file|
        content = compress_and_minify(entity)

        # replace paths to images or fonts by the absolute URL used in the Engine
        replace_assets!(content)

        file.write(content)

        entity.filepath = file.path

        file.close
      end
    end

    def replace_assets!(content)
      content.gsub!(/([("'])\/((images|fonts)\/[^)"']+)([)"''])/) do
        leading_char, local_path, trailing_char = $1, $2, $4
        local_path.gsub!(/\?[^\/]+\Z/, '') # remove query string if present
        "#{leading_char}#{(@remote_urls || {})[local_path] || local_path}#{trailing_char}"
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
          hash[entity.local_path] = entity
          register_url(entity)
        end
      end
    end

    def register_url(resource)
      @remote_urls ||= {}
      @remote_urls[resource.local_path] = "#{resource.url}?#{resource.checksum}"
    end

    def compress_and_minify(entity)
      begin
        sprockets_env[entity.short_relative_url].to_s
      rescue Exception => e
        instrument :warning, message: "Unable to compress and minify it, error: #{e.message}"
        # use the original file instead
        File.read(File.join(path, entity.source))
      end
    end

    def sprockets_env
      @sprockets_env ||= Locomotive::Steam::SprocketsEnvironment.new(File.join(path, 'public'),
        minify: ENV['WAGON_NO_MINIFY_ASSETS'].present? ? false : true)
    end

    def skip?(entity)
      return false if @only_entities.blank?

      _source = entity.source.gsub('./public/', '')

      !@only_entities.any? { |regexp| regexp.match(_source) }
    end

  end

end
