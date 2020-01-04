require 'tempfile'
require 'benchmark'

require_relative '../../../tools/yaml_ext.rb'

module Locomotive::Wagon

  module AssetsConcern

    REGEX = /((https?:\/\/\S+)?\/sites\/[0-9a-f]{24}\/(assets|pages|theme|content_entry[0-9a-f]{24})\/(([^;.]+)\/)*([a-zA-Z_\-0-9.%]+)(\?\w+)?)/

    # The content assets on the remote engine follows the format: /sites/<id>/assets/<type>/<file>
    # This method replaces these urls by their local representation. <type>/<file>
    #
    # @param [ String ] content The text where the assets will be replaced.
    #
    def replace_asset_urls(content)
      return '' if content.blank?

      _content = content.dup

      content.force_encoding('utf-8').scan(REGEX).map do |match|
        url, type, filename = match[0], match[2], match[5]
        folder = case type
        when 'assets', 'pages'  then File.join('samples', "_#{env}", type)
        when 'theme'            then $4
        when /\Acontent_entry/  then File.join('samples', "_#{env}", 'content_entries')
        end

        Thread.new do
          if filepath = write_asset(url, File.join(path, 'public', folder, filename))
            [url, File.join('', folder, File.basename(filepath)).to_s]
          else
            [url, '']
          end
        end
      end.map(&:value).each do |(url, replacement)|
        _content.gsub!(url, replacement)
      end

      _content
    end

    def replace_asset_urls_in_hash(hash)
      Locomotive::Wagon::YamlExt.transform(hash) do |value|
        replace_asset_urls(value)
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

        find_unique_filepath(File.join(folder, "#{basename}-#{index}#{ext}"), binary_file, index + 1)
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

        (binary_file = Tempfile.new(File.basename(filepath)).binmode).write(binary)

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
