require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Webpack < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :target_path # path to the site

        def copy_source
          directory('webpack', self.target_path, {
            recursive:  true
          })
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators')
        end

      end

    end
  end
end
