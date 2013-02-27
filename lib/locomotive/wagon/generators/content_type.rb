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

        argument :name
        argument :target_path
        argument :fields

        def copy_sources
          directory('.', target_path, { recursive: true }, {
            name:   self.name,
            fields: extract_fields(fields)
          })
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'content_type')
        end

        protected

        def extract_fields(fields)
          fields.map do |raw_attributes|
            name, type, required = raw_attributes.split(':')

            OpenStruct.new({
              name:     name,
              type:     type || 'string',
              required: %w(true required).include?(required)
            })
          end
        end

      end

    end
  end
end