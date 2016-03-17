require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class SiteMetafields < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :target_path # path to the site

        def create_metafields_schema
          path = File.join(target_path, 'config', 'metafields_schema.yml')

          template 'schema.yml.tt', path
        end

        def add_instructions
          append_to_file 'config/site.yml', <<-EOF

# You can control the display of the "Properties" section in the back-office
# metafields_ui:
#   label: Store settings # use a hash for localized versions
#   icon: shopping-cart # FontAwesome icons without the leading "fa-" string.
#   hint: "Lorem ipsum..."

# Each site can have its own set of custom properties organized in namespaces.
# First, define namespaces and their fields in the config/metafields_schema.yml file.
# Finally, set default values below as described in the example.
# You can access them in your liquid templates and snippets:
#   {{ site.metafields.<namespace>.<field> }}
#
# Example:
#
# metafields:
#   shop:
#     address: 700 South Laflin Street
#   theme:
#     background_image: "/samples/background.png"
EOF
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'site_metafields')
        end

        protected

        def snippets_path
          File.join(target_path, 'app', 'views', 'snippets')
        end

      end

    end
  end
end
