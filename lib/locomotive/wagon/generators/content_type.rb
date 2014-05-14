require 'thor/group'
require 'ostruct'
require 'active_support'
require 'active_support/core_ext'
require 'faker'

module Locomotive
  module Wagon
    module Generators
      class ContentType < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :slug
        argument :fields
        argument :target_path

        def copy_sources
          directory('.', target_path, { recursive: true }, {
            name:   name,
            slug:   slug,
            fields: extract_fields(fields)
          })
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'content_type')
        end

        protected

        def name
          options['name'] || slug.humanize
        end

        def extract_fields(fields)
          fields.map do |raw_attributes|
            name, type, label, required, localized, target_content_type_slug  = raw_attributes.split(':')

            OpenStruct.new(
              name:       name,
              label:      label || name.humanize,
              type:       type || 'string',
              required:   %w(true required).include?(required),
              localized:  %w(true required).include?(localized)
            ).tap do |field|
              if %w(belongs_to has_many many_to_many).include?(type)
                field.class_name = target_content_type_slug

                inverse_of = type == 'belongs_to' ? target_content_type_slug.singularize : target_content_type_slug

                field.inverse_of = inverse_of
              end
            end
          end
        end

      end

    end
  end
end