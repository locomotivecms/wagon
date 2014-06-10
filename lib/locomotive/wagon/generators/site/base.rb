require 'thor/group'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/core_ext/string/inflections'

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

          def comment_gemfile
            return unless skip_bundle?

            gsub_file File.join(self.destination, 'Gemfile'), /^(.*)$/ do |match|
              "# #{match}"
            end
          end

          def self.source_root
            File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'generators', self.name.demodulize.underscore)
          end

          def self.may_use_haml
            class_option :haml, type: :boolean, default: nil, required: false, desc: 'Use HAML templates?'
          end

          def self.may_use_scss
            class_option :scss, type: :boolean, default: nil, required: false, desc: 'Use SCSS stylesheets?'
          end

          protected

          def destination
            File.join(target_path, name)
          end

          def haml?
            if options[:haml].nil?
              yes?('Do you prefer HAML templates?')
            else
              options[:haml]
            end
          end

          def scss?
            if options[:scss].nil?
              yes?('Do you prefer SCSS stylesheets?')
            else
              options[:scss]
            end
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