module Locomotive
  module Builder
    module Liquid
      module Drops
        class ContentTypes < ::Liquid::Drop

          def before_method(meth)
            type = self.mounting_point.content_types[meth.to_s]
            ProxyCollection.new(type)
          end

        end

        class ProxyCollection < ::Liquid::Drop

          def initialize(content_type)
            @content_type = content_type
            @collection = nil
          end

          def first
            self.collection.first
          end

          def last
            self.collection.last
          end

          def size
            self.collection.size
          end

          alias :length :size

          def each(&block)
            self.collection.each(&block)
          end

          def public_submission_url
            "/entry_submissions/#{@content_type.slug}"
          end

          def api
            { 'create' => "/entry_submissions/#{@content_type.slug}" }
          end

          def before_method(meth)
            if (meth.to_s =~ /^group_by_(.+)$/) == 0
              # TODO
              @content_type.group_contents_by($1)
            elsif (meth.to_s =~ /^(.+)_options$/) == 0
              # TODO
              @content_type.select_names($1)
            else
              @content_type.send(meth)
            end
          end

          protected

          def paginate(options = {})
            @collection ||= self.collection.paginate(options)
            {
              collection:       @collection,
              current_page:     @collection.current_page,
              previous_page:    @collection.previous_page,
              next_page:        @collection.next_page,
              total_entries:    @collection.total_entries,
              total_pages:      @collection.total_pages,
              per_page:         @collection.per_page
            }
          end

          def collection
            return unless @collection.blank?

            if @context['with_scope'].blank?
              @collection = @content_type.entries
            else
              @collection = []

              conditions = @context['with_scope'].clone.delete_if { |k, _| %w(order_by per_page page).include?(k) }

              @content_type.entries.each do |content|
                accepted = (conditions.map do |key, value|
                  case value
                  when TrueClass, FalseClass, String then content.send(key) == value
                  else
                    true
                  end
                end).all? # all conditions works ?

                @collection << content if accepted
              end
            end

            @collection
          end
        end
      end
    end
  end
end