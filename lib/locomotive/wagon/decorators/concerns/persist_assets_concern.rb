require_relative '../../tools/yaml_ext.rb'

module Locomotive::Wagon

  module PersistAssetsConcern

    def replace_with_content_assets!(text)
      return text if text.blank?

      text.to_s.gsub(/\/samples\/\S*\.[a-zA-Z0-9]+/) do |match|
        url = __content_assets_pusher__.persist(match)
        url || match
      end
    end

    def replace_with_content_assets_in_hash!(hash)
      Locomotive::Wagon::YamlExt.transform(hash) do |value|
        replace_with_content_assets!(value)
      end
    end

    def asset_io(local_path)
      __content_assets_pusher__.decorate(local_path).source
    end

  end

end
