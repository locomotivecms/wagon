require 'locomotive/coal'

module Locomotive::Wagon

  module ToHashConcern

    def to_hash
      {}.tap do |hash|
        __attributes__.each do |name|
          value = self.public_send(name)

          next if value.nil?

          hash[name] = prepare_value_for_hash(value)
        end
      end
    end

    def prepare_value_for_hash(value)
      if value.is_a?(Array) && value.first.respond_to?(:__attributes__)
        value.map(&:to_hash)
      elsif value.is_a?(Array) && value.empty?
        nil # reset the array
      elsif value.respond_to?(:translations)
        !value.translations.empty? ? value.translations : nil
      else
        value
      end
    end

  end

end
