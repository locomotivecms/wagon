module Locomotive::Wagon

  class SyncSiteCommand < PullSiteCommand

    include Locomotive::Wagon::BaseConcern

    def _sync
      attributes = current_site.attributes.slice('name', 'timezone', 'seo_title', 'meta_keywords', 'meta_description', 'robots_txt', 'metafields', 'sections_content')

      locales.each_with_index do |locale, index|
        if index == 0
          transform_in_default_locale(attributes, locale)
        else
          add_other_locale(attributes, locale)
        end
      end if locales.size > 1

      decode_metafields(attributes)
      decode_sections_content(attributes)

      write_to_file(site_filepath, replace_asset_urls(JSON.neat_generate(attributes, {
        sort: true, short: false, padding: 1, object_padding: 1, after_colon: 1, after_comma: 1, wrap: 20, aligned: false
      })))
    end

    protected

    def site_filepath
      File.join('data', env.to_s, 'site.json')
    end

  end

end
