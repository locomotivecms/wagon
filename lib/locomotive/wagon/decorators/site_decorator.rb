module Locomotive
  module Wagon

    class SiteDecorator < SimpleDelegator

      include ToHashConcern

      def domains
        (__getobj__.domains || []) - ['localhost']
      end

      def robots_txt
        self[:robots_txt]
      end

      def __attributes__
        %i(name handle robots_txt locales domains timezone seo_title meta_keywords meta_description)
      end

    end

  end
end
