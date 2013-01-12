require 'locomotive/builder/generators/list'

module Locomotive
  module Builder

    module Generators

      # Register a generator by adding it to the list of existing generators.
      #
      # @param [ Symbol ] type The type of the generator (:site, :content_type)
      # @param [ String ] name The name of the generator
      # @param [ Class ] klass The class of the generator
      # @param [ String ] description The description of the generator (can be nil)
      #
      # @return [ Boolean ] True if the registration has been successful, false otherwise.
      #
      def self.register(type, name, klass, description = nil)
        Locomotive::Builder::Generators::List.instance.register(type, name, klass, description)
      end

      # Return the information about a generator from its name.
      #
      # @param [ String ] name The name of the generator
      #
      # @return [ Object ] The information of the found generator or nil
      #
      def self.get(name)
        Locomotive::Builder::Generators::List.instance.get(name)
      end

      # Filter the generators by their type which are for now:
      # :site and :content_type. If the parameter is nil,
      # then all the generators are returned
      #
      # @param [ Symbol ] type The type of the generators or nil.
      #
      # @return [ Array ] The filtered (or not) list of generators
      #
      def self.list(type = nil)
        Locomotive::Builder::Generators::List.instance.filter_by(type)
      end

      # Tell if the list of generators is empty or not for
      # a certain kind of generators (or all if the parameter is nil).
      #
      # @param [ Symbol ] type The type of the generators or nil
      #
      # @return [ Boolean ] True if empty
      #
      def self.empty?(type = nil)
        Locomotive::Builder::Generators::List.instance.empty?(type)
      end

    end

  end
end

# call default generators
require 'locomotive/builder/generators/base'
require 'locomotive/builder/generators/defaults'
