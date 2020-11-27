require_relative '../../tools/yaml_ext.rb'

module Locomotive::Wagon

  module PersistAssetsConcern

    def replace_with_content_assets!(text)
      return text if text.blank?

      text.to_s.gsub(/([^a-zA-Z0-9]|^)(\/samples\/[\/a-zA-Z0-9_-]+(\.[a-zA-Z0-9]+)*)/) do
        url = __content_assets_pusher__.persist($2) || $2
        $1 + url
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
