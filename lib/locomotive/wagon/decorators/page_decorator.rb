module Locomotive
  module Wagon

    class PageDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern

      def __attributes__
        %i(title slug handle response_type published
          position listed
          is_layout allow_layout
          redirect_url redirect_type
          seo_title meta_keywords meta_description
          editable_elements
          template)
      end

      def is_layout
        self[:is_layout]
      end

      def allow_layout
        self[:allow_layout]
      end

      def response_type
        self[:response_type]
      end

      def editable_elements
        __getobj__.editable_elements.all.map do |element|
          EditableElementDecorator.new(element, __locale__)
        end
      end

      def template
        self.liquid_source
      end

    end

  end
end
