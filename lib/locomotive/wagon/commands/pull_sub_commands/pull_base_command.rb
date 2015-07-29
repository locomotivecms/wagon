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

    def dump(element, options = {})
      if element.is_a?(Hash)
        StyledYAML.dump(element.dup.tap do |attributes|
          [*options[:inline]].each do |name|
            attributes[name] = StyledYAML.inline(attributes[name])
          end
        end)
      else
        element.to_yaml
      end.gsub(/\A---\n/, '')
    end

    def clean_attributes(attributes)
      # remove nil or empty values
      attributes.delete_if { |_, v| v.nil? || v == '' || (v.is_a?(Hash) && v.empty?) }
    end

    def write_to_file(filepath, content = nil, mode = 'w+', &block)
      _filepath = File.join(path, filepath)

      folder = File.dirname(_filepath)
      FileUtils.mkdir_p(folder) unless File.exists?(folder)

      File.open(_filepath, mode) do |file|
        file.write(content ? content : yield)
      end
    end

    def reset_file(filepath)
      FileUtils.rm(filepath) if File.exists?(filepath)
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
