module Locomotive
  module Wagon

    class PageDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern

      # def id
      #   slug
      # end

      # def template
      #   {}.tap do |translations|
      #     __getobj__.template_path.translations.each do |locale, _|
      #       __with_locale__(locale) do
      #         translations[locale] = self.liquid_source
      #       end
      #     end
      #   end
      # end

      def __attributes__
        %i(title)
      end

    end

  end
end
