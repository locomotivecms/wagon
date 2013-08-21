module Locomotive
  module Wagon
    module Liquid
      class PageNotFound < ::Liquid::Error; end

      class PageNotTranslated < ::Liquid::Error; end

      class UnknownConditionInScope < ::Liquid::Error; end
    end
  end
end