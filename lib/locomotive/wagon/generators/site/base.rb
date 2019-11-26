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
          argument :skip_bundle

          def copy_sources
            copy_sources_from_generator
          end

          def remove_gemfile
            return if skip_bundle?

            remove_file File.join(self.destination, 'Gemfile')
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

          def skip_bundle?
            [true, 'true'].include?(skip_bundle)
          end

          def bundle_install
            return if skip_bundle?

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
