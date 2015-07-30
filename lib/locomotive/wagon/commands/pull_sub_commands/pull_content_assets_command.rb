module Locomotive::Wagon

  class PullContentAssetsCommand < PullBaseCommand

    def _pull
      api_client.content_assets.all.each do |asset|
        write_content_asset(asset)
      end
    end

    def write_content_asset(asset)
      binary = get_asset_binary(asset.url)
      write_to_file(content_asset_filepath(asset), binary)
    end

    private

    def content_asset_filepath(asset)
      File.join('public', 'samples', 'all', asset.content_type_text, asset.filename)
    end

  end

end
