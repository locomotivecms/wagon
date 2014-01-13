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

          def self.may_use_haml
            class_option :haml, type: :boolean, default: nil, required: false, desc: 'HAML over HTML?'
          end

          protected

          def haml?
            if options[:haml].nil?
              yes?('Do you prefer HAML templates ?')
            else
              options[:haml]
            end
          end

        end

      end
    end
  end
end