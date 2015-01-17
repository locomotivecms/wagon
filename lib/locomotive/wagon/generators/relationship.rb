require 'thor/group'
require 'thor/error'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Relationship < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :source  # slug of a content type
        argument :type    # belongs_to, has_many or many_to_many
        argument :target  # slug of a content type
        argument :target_path # path to the site

        def content_types_must_exist
          unless File.exists?(File.join(destination_root, source_path))
            fail Thor::Error, "The #{source} content type does not exist"
          end

          unless File.exists?(File.join(destination_root, target_path))
            fail Thor::Error, "The #{target} content type does not exist"
          end
        end

        def modify_content_types
          case type.to_sym
          when :belongs_to
            append_to_file source_path, build_belongs_to_field(source, target)
            append_to_file target_path, build_has_many_field(target, source)
          when :has_many
            append_to_file source_path, build_has_many_field(source, target)
            append_to_file target_path, build_belongs_to_field(target, source)
          when :many_to_many
            append_to_file source_path, build_many_to_many_field(source, target)
            append_to_file target_path, build_many_to_many_field(target, source)
          else
            fail Thor::Error, "#{type} is an unknown relationship type"
          end
        end

        protected

        def source_path
          "app/content_types/#{source}.yml"
        end

        def target_path
          "app/content_types/#{target}.yml"
        end

        def build_belongs_to_field(source_class, target_class)
          in_yaml({
            target_class.singularize => {
              'label'       => target_class.singularize.humanize,
              'type'        => 'belongs_to',
              'class_name'  => target_class
            }
          })
        end

        def build_has_many_field(source_class, target_class)
          in_yaml({
            target_class => {
              'label'       => target_class.humanize,
              'type'        => 'has_many',
              'class_name'  => target_class,
              'inverse_of'  => source_class.singularize,
              'ui_enabled'  => true
            }
          })
        end

        def build_many_to_many_field(source_class, target_class)
          in_yaml({
            target_class => {
              'label'       => target_class.humanize,
              'type'        => 'many_to_many',
              'class_name'  => target_class,
              'inverse_of'  => source_class,
              'ui_enabled'  => true
            }
          })
        end

        def in_yaml(hash)
          [hash].to_yaml.gsub(/^(---\s+)/, "\n")
        end

      end

    end
  end
end
