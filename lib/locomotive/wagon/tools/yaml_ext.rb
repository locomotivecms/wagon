module Locomotive
  module Wagon

    module YamlExt

      def self.transform(hash, &block)
        return if hash.blank? || !hash.respond_to?(:has_key?)

        hash.each do |key, value|
          case value
          when Hash   then transform(value, &block)
          when Array  then value.each { |v| transform(v, &block) }
          when String then hash[key] = yield(value)
          end
        end
      end

    end

  end
end
