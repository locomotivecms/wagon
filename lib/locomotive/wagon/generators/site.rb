require 'ostruct'
require 'singleton'

module Locomotive
  module Wagon
    module Generators

      module Site

        # Register a generator by adding it to the list of existing generators.
        #
        # @param [ String ] name The name of the generator
        # @param [ Class ] klass The class of the generator
        # @param [ String ] description The description of the generator (can be nil)
        #
        # @return [ Boolean ] True if the registration has been successful, false otherwise.
        #
        def self.register(name, klass, description = nil)
          Locomotive::Wagon::Generators::Site::List.instance.register(name, klass, description)
        end

        # Return the information about a generator from its name.
        #
        # @param [ String ] name The name of the generator
        #
        # @return [ Object ] The information of the found generator or nil
        #
        def self.get(name)
          Locomotive::Wagon::Generators::Site::List.instance.get(name)
        end

        # List all the generators
        #
        # @return [ Array ] The filtered (or not) list of generators
        #
        def self.list
          Locomotive::Wagon::Generators::Site::List.instance._list
        end

        # Tell if the list of generators is empty or not .
        #
        # @return [ Boolean ] True if empty
        #
        def self.empty?
          Locomotive::Wagon::Generators::Site::List.instance._list.empty?
        end

        class List

          include ::Singleton

          attr_accessor :_list

          def initialize
            self._list = []
          end

          # Return the information about a generator from its name.
          #
          # @param [ String ] name The name of the generator
          #
          # @return [ Object ] The information of the found generator or nil
          #
          def get(name)
            self._list.detect { |entry| entry.name == name.to_sym }
          end

          # Register a generator by adding it to the list of existing generators.
          #
          # @param [ String ] name The name of the generator
          # @param [ Class ] klass The class of the generator
          # @param [ String ] description The description of the generator (can be nil)
          #
          # @return [ Boolean ] True if the registration has been successful, false otherwise.
          #
          def register(name, klass, description = nil)
            return false unless self.get(name).nil?

            self._list << OpenStruct.new({
              name:         name.to_sym,
              klass:        klass,
              description:  description ? description.strip.gsub("\n", '') : nil
            })

            self._list.last
          end
        end

      end

    end
  end
end

require 'locomotive/wagon/generators/site/base'
require 'locomotive/wagon/generators/site/blank'
require 'locomotive/wagon/generators/site/bootstrap2'
require 'locomotive/wagon/generators/site/foundation'
require 'locomotive/wagon/generators/site/unzip'
require 'locomotive/wagon/generators/site/cloned'
