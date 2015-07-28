require_relative './concerns/assets_concern'

module Locomotive::Wagon

  class PullBaseCommand < Struct.new(:api_client, :current_site, :path)

    include Locomotive::Wagon::AssetsConcern

    def self.pull(api_client, current_site, path)
      new(api_client, current_site, path).pull
    end

    def pull
      instrument do
        instrument :start
        self._pull_with_timezone
        instrument :done
      end
    end

    def _pull_with_timezone
      Time.use_zone(current_site.try(:timezone)) do
        _pull
      end
    end

    def instrument(action = nil, payload = {}, &block)
      name = ['wagon.pull', [*action]].flatten.compact.join('.')
      ActiveSupport::Notifications.instrument(name, { name: resource_name }.merge(payload), &block)
    end

    def dump(attributes, options)
      _attributes = attributes.dup

      [*options[:inline]].each do |name|
        _attributes[name] = StyledYAML.inline(_attributes[name])
      end

      StyledYAML.dump(_attributes).gsub(/\A---\n/, '')
    end

    def write_to_file(filepath, content = nil, &block)
      File.open(File.join(path, filepath), 'w+') do |file|
        file.write(content ? content : yield)
      end
    end

    def resource_name
      self.class.name[/::Pull(\w+)Command$/, 1].underscore
    end

    def default_locale
      current_site.locales.first
    end

    def locales
      current_site.locales
    end

  end

end
