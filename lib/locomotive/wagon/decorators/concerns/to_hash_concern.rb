require 'locomotive/coal'

module Locomotive::Wagon

  module ToHashConcern

    def to_hash
      {}.tap do |hash|
        __attributes__.each do |name|
          if !(value = self.send(name)).nil?
            if value.is_a?(Array) && value.first.respond_to?(:__attributes__)
              hash[name] = value.map(&:to_hash)
            elsif value.respond_to?(:translations)
              hash[name] = value.translations unless value.translations.empty?
            else
              hash[name] = value
            end
          end
        end
      end
    end

  end

end
