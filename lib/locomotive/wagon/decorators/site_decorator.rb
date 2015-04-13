module Locomotive
  module Wagon

    class SiteDecorator < SimpleDelegator

      def domains
        (__getobj__.domains || []) - ['localhost']
      end

      def to_hash
        {}.tap do |hash|
          %i(name handle robots_txt locales domains timezone seo_title meta_keywords meta_description).each do |name|
            if value = self[name]
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
end
