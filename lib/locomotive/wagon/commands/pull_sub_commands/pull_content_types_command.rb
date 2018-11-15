module Locomotive::Wagon

  class PullContentTypesCommand < PullBaseCommand

    def _pull
      api_client.content_types.all.each do |content_type|
        write_content_type(content_type)
      end
    end

    def write_content_type(content_type)
      yaml = dump(yaml_attributes(content_type), inline: %w(public_submission_account_emails))

      write_to_file(content_type_filepath(content_type), yaml)
    end

    private

    def yaml_attributes(content_type)
      content_type.attributes.slice('name', 'slug', 'description', 'label_field_name', 'order_by', 'order_direction', 'group_by', 'public_submission_enabled', 'public_submission_account_emails', 'display_settings').tap do |attributes|
        # fields
        attributes['fields'] = content_type.fields.map { |f| field_yaml_attributes(f) }

        clean_attributes(attributes)
      end
    end

    def field_yaml_attributes(field)
      attributes = field.slice('label', 'type', 'required', 'hint', 'localized', 'select_options', 'target', 'inverse_of', 'ui_enabled', 'group')

      clean_attributes(attributes)

      # select_options
      attributes['select_options'] = select_options_yaml(attributes['select_options']) if field['type'] == 'select'

      { field['name'] => attributes }
    end

    def select_options_yaml(options)
      return if options.blank?

      ordered_options = options.sort { |option| option['position'] }

      if locales.size > 1
        {}.tap do |_options|
          ordered_options.each do |option|
            locales.each { |locale| (_options[locale] ||= []) << option['name'][locale.to_s] }
          end

          # if all the values of a locale are nil, then no need to keep that locale
          locales.each do |locale|
            _options.delete(locale) if _options[locale].all? { |v| v.blank? }
          end
        end
      else
        ordered_options.map { |option| option['name'][default_locale] }
      end
    end

    def content_type_filepath(content_type)
      File.join('app', 'content_types', "#{content_type.slug}.yml")
    end

  end

end
