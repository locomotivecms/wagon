module Locomotive
  module Wagon

    class ContentTypeDecorator < SimpleDelegator

      include ToHashConcern

      def initialize(entity, existing_fields = [])
        @existing_fields = existing_fields
        super(entity)
      end

      def __attributes__
        %i(name slug description label_field_name tree_parent_field_name fields
          order_by order_direction group_by
          public_submission_enabled
          public_submission_accounts
          public_submission_title_template
          public_submission_email_attachments
          recaptcha_required entry_template display_settings filter_fields)
      end

      def fields
        return @fields if @fields

        @fields = __getobj__.fields.no_associations.map { |f| ContentTypeFieldDecorator.new(f, @existing_fields.include?(f.name)) }

        @existing_fields.each do |name|
          # the field exists remotely but does not exist locally, delete it
          if __getobj__.fields.by_name(name).nil?
            @fields.insert(0, { name: name, _destroy: true })
          end
        end

        @fields
      end

      def description
        self[:description]
      end

      def order_by
        self[:order_by]
      end

      def group_by
        self[:group_by]
      end

      def public_submission_enabled
        self[:public_submission_enabled]
      end

      def public_submission_accounts
        self[:public_submission_accounts]
      end

      def public_submission_title_template
        self[:public_submission_title_template]
      end

      def public_submission_email_attachments
        self[:public_submission_email_attachments]
      end

      def entry_template
        self[:entry_template]
      end

      def display_settings
        self[:display_settings]
      end

      def filter_fields
        self[:filter_fields]
      end

      def tree_parent_field_name
        self[:tree_parent_field_name]
      end

      def recaptcha_required
        self[:recaptcha_required]
      end

      def with_relationships?
        __getobj__.fields.associations.count > 0
      end

    end

    class ContentTypeWithOnlyRelationshipsDecorator < ContentTypeDecorator

      def __attributes__
        %i(name slug fields)
      end

      def fields
        @fields ||= __getobj__.fields.associations.map { |f| ContentTypeFieldDecorator.new(f) }
      end

    end

  end
end
