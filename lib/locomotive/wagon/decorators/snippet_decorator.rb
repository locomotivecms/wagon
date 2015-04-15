module Locomotive
  module Wagon

    class SnippetDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern

      def id
        slug
      end

      def template
        {}.tap do |translations|
          __getobj__.template_path.translations.each do |locale, _|
            __with_locale__(locale) do
              translations[locale] = self.liquid_source
            end
          end
        end
      end

      def __attributes__
        %i(name slug template)
      end

    end

  end
end
