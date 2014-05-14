require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      module Site

        class Base < Thor::Group

          include Thor::Actions
          include Locomotive::Wagon::CLI::ForceColor

          argument :name
          argument :target_path
          argument :skip_bundle

          def copy_sources
            directory('.', self.destination, { recursive: true }, {
              name:     self.name,
              version:  Locomotive::Wagon::VERSION
            })
          end

          def self.source_root
            File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'generators', self.name.demodulize.underscore)
          end

          def self.may_use_haml
            class_option :haml, type: :boolean, default: nil, required: false, desc: 'HAML over HTML?'
          end

          protected

          def destination
            File.join(target_path, name)
          end

          def haml?
            puts options.inspect
            if options[:haml].nil?
              yes?('Do you prefer HAML templates ?')
            else
              options[:haml]
            end
          end

          def bundle_install
            return if [true, 'true'].include?(skip_bundle)

            FileUtils.cd self.destination

            say_status :run, "bundle install"

            ENV['BUNDLE_GEMFILE'] = nil

            print `"#{Gem.ruby}" -rubygems "#{Gem.bin_path('bundler', 'bundle')}" install`
          end

        end

      end
    end
  end
end