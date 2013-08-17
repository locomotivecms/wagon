unless Hash.instance_methods.include?(:underscore_keys)
  class Hash

    def underscore_keys
      new_hash = {}

      self.each_pair do |key, value|
        if value.respond_to?(:collect!) # Array
          value.collect do |item|
            if item.respond_to?(:each_pair) # Hash item within
              item.underscore_keys
            else
              item
            end
          end
        elsif value.respond_to?(:each_pair) # Hash
          value = value.underscore_keys
        end

        new_key = key.is_a?(String) ? key.underscore : key # only String keys

        new_hash[new_key] = value
      end

      self.replace(new_hash)
    end

  end
end

unless String.instance_methods.include?(:to_bool)
  class String
    def to_bool
      return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
      return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
    end
  end

  class TrueClass
    def to_bool; self; end
  end

  class FalseClass
    def to_bool; self; end
  end
end

unless Array.instance_methods.include?(:contains?)
  class Array
    def contains?(other); (self & other) == other; end
  end
end

