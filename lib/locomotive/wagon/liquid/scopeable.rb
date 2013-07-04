module Locomotive
  module Wagon
    module Liquid
      module Scopeable

        def apply_scope(entries)
          if @context['with_scope'].blank?
            entries
          else
            collection = []

            conditions = @context['with_scope'].clone.delete_if { |k, _| %w(order_by per_page page).include?(k) }

            entries.each do |content|
              accepted = (conditions.map do |key, value|
                case value
                when TrueClass, FalseClass, String, Integer then content.send(key) == value
                else
                  true
                end
              end).all? # all conditions works ?

              collection << content if accepted
            end
            collection
          end
        end

      end
    end
  end
end