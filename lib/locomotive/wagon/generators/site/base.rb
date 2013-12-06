require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      module Site

        class Base < Thor::Group

          include Thor::Actions

          argument :name
          argument :target_path

          def copy_sources
            directory('.', self.destination, { recursive: true }, {
              name:     self.name,
              version:  Locomotive::Wagon::VERSION
            })
          end

          def self.source_root
            File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'generators', self.name.demodulize.underscore)
          end

          def destination
            File.join(target_path, name)
          end

        end

      end
    end
  end
end