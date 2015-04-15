require 'locomotive/coal'

module Locomotive::Wagon

  module ToHashConcern

    def to_hash
      {}.tap do |hash|
        __attributes__.each do |name|
          if value = self.send(name)
            if value.respond_to?(:translations)
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
