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
      attributes = field.slice('label', 'type', 'required', 'hint', 'localized', 'select_options', 'class_name', 'inverse_of', 'ui_enabled')

      clean_attributes(attributes)

      { field['name'] => attributes }
    end

    def content_type_filepath(content_type)
      File.join('app', 'content_types', "#{content_type.slug}.yml")
    end

  end

end
