module Locomotive::Wagon

  class PullSiteCommand < PullBaseCommand

    def _pull
      attributes = current_site.attributes.slice('name', 'locales', 'domains', 'timezone', 'seo_title', 'meta_keywords', 'meta_description', 'picture_thumbnail_url')

      locales.each_with_index do |locale, index|
        if index == 0
          transform_in_default_locale(attributes, locale)
        else
          add_other_locale(attributes, locale)
        end
      end if locales.size > 1

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

    def localized_attributes(&block)
      %w(seo_title meta_keywords meta_description).each do |name|
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
