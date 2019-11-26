require 'thor/group'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/core_ext/string/inflections'
require 'locomotive/wagon/version'

module Locomotive
  module Wagon
    module Generators
      module Site

        class Base < Thor::Group

          include Thor::Actions
          include Locomotive::Wagon::CLI::ForceColor

          argument :name
          argument :target_path

          def copy_sources
            copy_sources_from_generator
          end

          def self.source_root
            File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'generators')
          end

          protected

          def copy_sources_from_generator(generator_name: nil, options: {})
            _name = generator_name || self.class.name.demodulize.underscore

            directory(_name, self.destination, {
              recursive:  true,
              name:       self.name,
              version:    Locomotive::Wagon::VERSION
            }.merge(options))
          end

          def destination
            File.join(target_path, name)
          end

        end

      end
    end
  end
end
