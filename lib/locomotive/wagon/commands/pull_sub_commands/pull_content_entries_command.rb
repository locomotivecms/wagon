module Locomotive::Wagon

  class PullContentEntriesCommand < PullBaseCommand

    def _pull
      fetch_content_types do |content_type|
        # delete the previous file
        reset_file(content_entry_filepath(content_type))

        instrument :writing, label: content_type.name

        fetch_content_entries(content_type) do |entries|
          # entries is a list of max 10 elements (pagination)
          write_content_entries(content_type, entries)
        end

        instrument :write_with_success
      end
    end

    def write_content_entries(content_type, entries)
      _entries = entries.map do |entry|
        yaml_attributes(content_type, entry)
      end

      write_to_file(content_entry_filepath(content_type), dump(_entries), 'a')
    end

    private

    def yaml_attributes(content_type, entry)
      fields            = %w(_slug) + content_type.fields.map { |f| f['name'] } + %w(seo_title meta_description meta_keywords)
      localized_fields  = (content_type.attributes['localized_names'] || []) + %w(_slug seo_title meta_description meta_keywords)

      attributes = {}

      fields.each do |name|
        attributes[name] = if localized_fields.include?(name) && locales.size > 1 && !content_type.attributes['localized_names'].empty?
          clean_attributes({}.tap do |translations|
            locales.each { |l| translations[l] = value_of(content_type, entry, l, name) }
          end)
        else
          value_of(content_type, entry, default_locale, name)
        end
      end

      attributes['_id'] = [entry[default_locale].attributes['_id'], entry[default_locale].attributes['_slug']]

      attributes['_visible'] = false unless entry[default_locale].attributes['_visible'] == true

      { entry[default_locale].attributes[content_type.label_field_name].to_s => clean_attributes(attributes) }
    end

    def fetch_content_types(&block)
      api_client.content_types.all.each do |content_type|
        content_type.attributes['localized_names'] = content_type.fields.map { |f| f['localized'] ? f['name'] : nil }.compact
        content_type.attributes['urls_names'] = content_type.fields.map { |f| %w(file string text).include?(f['type']) ? f['name'] : nil }.compact
        yield(content_type)
      end
    end

    def fetch_content_entries(content_type, &block)
      page = 1
      while page do
        entries, _next_page = {}, nil

        locales.each do |locale|
          next if locale != default_locale && content_type.localized_names.empty?

          (_entries = api_client.content_entries(content_type).all(nil, { page: page, order_by: 'created asc' }, locale)).each do |entry|
            (entries[entry._id] ||= {})[locale] = entry
          end

          _next_page = _entries._next_page if _next_page.nil?
        end

        yield(entries.values)

        page = _next_page
      end
    end

    def value_of(content_type, entry, locale, name)
      # attribute not translated
      return nil if entry[locale].nil?

      if value = entry[locale].attributes[name]
        if content_type.attributes['urls_names'].try(:include?, name)
          replace_asset_urls(value)
        else
          value
        end
      else
        nil
      end
    end

    def content_entry_filepath(content_type)
      File.join('data', env, 'content_entries', "#{content_type.slug}.yml")
    end

  end

end
