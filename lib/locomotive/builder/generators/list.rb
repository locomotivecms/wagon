require 'ostruct'
require 'singleton'

module Locomotive
  module Builder
    module Generators
      class List

        include ::Singleton

        attr_accessor :_list

        def initialize
          self._list = []
        end

        # Filter the generators by their type which are for now:
        # :site and :content_type. If the parameter is nil,
        # then all the generators are returned
        #
        # @param [ Symbol ] type The type of the generators or nil.
        #
        # @return [ Array ] The filtered (or not) list of generators
        #
        def filter_by(type = nil)
          if type.nil?
            self._list
          else
            self._list.find_all { |entry| entry.type == type.to_sym }
          end
        end

        # Tell if the list of generators is empty or not for
        # a certain kind of generators (or all if the parameter is nil).
        #
        # @param [ Symbol ] type The type of the generators or nil
        #
        # @return [ Boolean ] True if empty
        #
        def empty?(type = nil)
          self.filter_by(type).empty?
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
        # @param [ Symbol ] type The type of the generator (:site, :content_type)
        # @param [ String ] name The name of the generator
        # @param [ Class ] klass The class of the generator
        # @param [ String ] description The description of the generator (can be nil)
        #
        # @return [ Boolean ] True if the registration has been successful, false otherwise.
        #
        def register(type, name, klass, description = nil)
          return false unless self.get(name).nil?

          self._list << OpenStruct.new({
            type:         type.to_sym,
            name:         name.to_sym,
            klass:        klass,
            description:  description.strip.gsub("\n", '')
          })

          self._list.last
        end

      end
    end
  end
end