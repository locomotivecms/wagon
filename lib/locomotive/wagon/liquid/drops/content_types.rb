module Locomotive
  module Wagon
    module Liquid
      module Drops
        class ContentTypes < ::Liquid::Drop

          def before_method(meth)
            type = self.mounting_point.content_types[meth.to_s]
            ProxyCollection.new(type)
          end

        end

        class ProxyCollection < ::Liquid::Drop

          include Scopeable

          def initialize(content_type)
            @content_type = content_type
            @collection = nil
          end

          def all
            self.collection
          end

          def any
            self.collection.any?
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
          alias :count :size

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
              self.group_entries_by(@content_type, $1)
            elsif (meth.to_s =~ /^(.+)_options$/) == 0
              self.select_options_for(@content_type, $1)
            else
              @content_type.send(meth)
            end
          end

          protected

          def group_entries_by(content_type, name)
            field = @content_type.find_field(name)

            return {} if field.nil? || !%w(belongs_to select).include?(field.type.to_s)

            (@content_type.entries || []).group_by do |entry|
              entry.send(name.to_sym)
            end.to_a.collect do |group|
              { name: group.first, entries: group.last }.with_indifferent_access
            end
          end

          def select_options_for(content_type, name)
            field = @content_type.find_field(name)

            return {} if field.nil? || field.type.to_s != 'select'

            field.select_options.map(&:name)
          end

          def paginate(options = {})
            @collection = self.collection.paginate(options)
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
            return @collection unless @collection.blank?

            # define the default order_by if not set
            if @context['with_scope'] && @context['with_scope']['order_by'].blank? && !%w(manually position).include?(@content_type.order_by)
              field     = @content_type.order_by || 'created_at'
              direction = @content_type.order_direction || 'asc'
              @context['with_scope']['order_by'] = "#{field}.#{direction}"
            end

            @collection = apply_scope(@content_type.entries)
          end
        end
      end
    end
  end
end
