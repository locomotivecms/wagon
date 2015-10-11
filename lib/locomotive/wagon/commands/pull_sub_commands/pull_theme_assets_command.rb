module Locomotive::Wagon

  class PullThemeAssetsCommand < PullBaseCommand

    def _pull
      api_client.theme_assets.all.each do |asset|
        write_theme_asset(asset)
      end
    end

    def write_theme_asset(asset)
      binary = get_asset_binary(asset.url)

      if %w(javascript stylesheet).include?(asset.content_type)
        binary = replace_asset_urls(binary)
      end

      write_to_file(theme_asset_filepath(asset), binary)
    end

    private

    def theme_asset_filepath(asset)
      File.join('public', asset.local_path)
    end

  end

end
