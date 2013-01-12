require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Builder
    module Generators

      class Base < Thor::Group

        include Thor::Actions

        argument :name
        argument :target_path

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', self.name.demodulize.underscore)
        end

        def destination
          File.join(target_path, name)
        end

      end

    end
  end
end