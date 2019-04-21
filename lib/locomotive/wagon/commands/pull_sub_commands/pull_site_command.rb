module Locomotive::Wagon

  class PullSiteCommand < PullBaseCommand

    def _pull
      attributes = current_site.attributes.slice(
        'name', 'locales', 'domains', 'timezone', 'seo_title',
        'meta_keywords', 'meta_description', 'picture_thumbnail_url',
        'metafields', 'metafields_schema', 'metafields_ui',
        'robots_txt', 'asset_host', 'sections_content'
      )

      locales.each_with_index do |locale, index|
        if index == 0
          transform_in_default_locale(attributes, locale)
        else
          add_other_locale(attributes, locale)
        end
      end if locales.size > 1

      decode_metafields(attributes)
      decode_metafields_ui(attributes)
      decode_sections_content(attributes)

      write_metafields_schema(attributes.delete('metafields_schema'))

      write_icon(attributes.delete('picture_thumbnail_url'))

      write_to_file(File.join('config', 'site.yml')) do
        dump(attributes, inline: %w(locales domains))
      end
    end

    private

    def write_icon(url)
      return if url.blank?

      unless url =~ /\Ahttp:\/\//
        base = api_client.uri.dup.tap { |u| u.path = '' }.to_s
        url = URI.join(base, url).to_s
      end

      File.open(File.join(path, 'icon.png'), 'wb') do |file|
        file.write Faraday.get(url).body
      end
    end

    def decode_metafields_schema(schema)
      if schema.is_a?(Array)
        schema = array_of_hash_to_hash(schema, 'name') do |namespace|
          namespace['fields'] = array_of_hash_to_hash(namespace.delete('fields'), 'name')
        end
      end

      schema
    end

    def write_metafields_schema(json)
      return if json.blank?

      schema = decode_metafields_schema(JSON.parse(json))

      File.open(File.join(path, 'config', 'metafields_schema.yml'), 'wb') do |file|
        file.write schema.to_yaml
      end
    end

    def decode_metafields(attributes)
      decode_json_attribute(attributes, 'metafields') do |metafields|
        replace_asset_urls_in_hash(metafields)
      end
    end

    def decode_metafields_ui(attributes)
      decode_json_attribute(attributes, 'metafields_ui')
    end

    def decode_sections_content(attributes)
      decode_json_attribute(attributes, 'sections_content') do |sections_content|
        replace_asset_urls_in_hash(sections_content)
      end
    end

    def array_of_hash_to_hash(array, name, &block)
      {}.tap do |hash|
        (array || []).each do |element|
          key = element.delete(name)
          hash[key] = element
          yield element if block_given?
        end
      end
    end

    def decode_json_attribute(attributes, name, &block)
      value = attributes.delete(name)

      return if value.blank?

      if value.is_a?(Hash)
        attributes[name] = {}

        value.each do |locale, _value|
          __value = JSON.parse(_value)
          attributes[name][locale] = block_given? ? yield(__value) : __value
        end
      else
        _value = JSON.parse(value)
        attributes[name] = block_given? ? yield(_value) : _value
      end
    end

    def localized_attributes(&block)
      %w(seo_title meta_keywords meta_description sections_content).each do |name|
        yield(name)
      end
    end

    def transform_in_default_locale(attributes, locale)
      localized_attributes { |k| attributes[k] = { locale => attributes[k] } }
    end

    def add_other_locale(attributes, locale)
      _site = api_client.current_site.get(locale)
      localized_attributes { |k| attributes[k][locale] = _site.attributes[k] }
    end

  end

end
