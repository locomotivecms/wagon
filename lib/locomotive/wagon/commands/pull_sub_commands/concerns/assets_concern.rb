require 'tempfile'

module Locomotive::Wagon

  module AssetsConcern

    # The content assets on the remote engine follows the format: /sites/<id>/assets/<type>/<file>
    # This method replaces these urls by their local representation. <type>/<file>
    #
    # @param [ String ] content The text where the assets will be replaced.
    #
    def replace_asset_urls(content)
      return '' if content.blank?

      content.force_encoding('utf-8').gsub(/\/sites\/[0-9a-f]{24}\/(assets|pages)\/(([^;.]+)\/)*([a-zA-Z_\-0-9]+)\.([a-z]{2,3})/) do |url|
        if filepath = write_asset(url, File.join(path, 'public', 'samples', $1, "#{$4}.#{$5}"))
          "/samples/#{$1}/#{File.basename(filepath)}"
        else
          ''
        end
      end
    end

    private

    def find_unique_filepath(filepath, binary_file, index = 1)
      if File.exists?(filepath)
        # required because we need to make sure we use the content of file from its start
        binary_file.rewind

        return filepath if FileUtils.compare_stream(binary_file, File.open(filepath))

        folder, ext = File.dirname(filepath), File.extname(filepath)
        basename = File.basename(filepath, ext)

        find_unique_filepath(File.join(folder, "#{basename}-#{index}#{ext}"), binary, index + 1)
      else
        filepath
      end
    end

    def get_asset_binary(url)
      unless url =~ /\Ahttp:\/\//
        base = api_client.uri.dup.tap { |u| u.path = '' }.to_s
        url = URI.join(base, url).to_s
      end

      binary = Faraday.get(url).body rescue nil
    end

    def write_asset(url, filepath)
      if binary = get_asset_binary(url)
        FileUtils.mkdir_p(File.dirname(filepath))

        (binary_file = Tempfile.new(File.basename(filepath))).write(binary)

        find_unique_filepath(filepath, binary_file).tap do |filepath|
          File.open(filepath, 'wb') { |f| f.write(binary) }
        end
      else
        instrument :missing_asset, url: url
        nil
      end
    end

  end

end
