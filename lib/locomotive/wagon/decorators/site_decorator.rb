module Locomotive
  module Wagon

    class SiteDecorator < SimpleDelegator

      include ToHashConcern

      def domains
        (__getobj__.domains || []) - ['localhost']
      end

      %i(robots_txt locales timezone seo_title meta_keywords meta_description).each do |name|
        define_method(name) do
          self[name]
        end
      end

      def __attributes__
        %i(name handle robots_txt locales timezone seo_title meta_keywords meta_description)
      end

    end

  end
end
