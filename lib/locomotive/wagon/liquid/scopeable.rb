module Locomotive
  module Wagon
    module Liquid
      module Scopeable

        def apply_scope(entries)
          if @context['with_scope'].blank?
            entries
          else
            # extract the conditions
            _conditions = @context['with_scope'].clone.delete_if { |k, _| %w(order_by per_page page).include?(k) }

            # build the chains of conditions
            conditions = _conditions.map { |name, value| Condition.new(name, value) }

            Locomotive::Wagon::Logger.info "[with_scope] conditions: #{conditions.map(&:to_s).join(', ')}"

            # get only the entries matching ALL the conditions
            entries.find_all do |content|
              accepted = true

              conditions.each do |_condition|
                unless _condition.matches?(content)
                  accepted = false
                  break # no to go further
                end
              end

              accepted
            end
          end
        end

        class Condition

          OPERATORS = %w(all gt gte in lt lte ne nin size)

          attr_accessor :name, :operator, :right_operand

          def initialize(name, value)
            self.name, self.right_operand = name, value

            # default value
            self.operator = :==

            self.decode_operator_based_on_name
          end

          def matches?(entry)
            value = entry.send(self.name)

            self.decode_operator_based_on_value(value)

            case self.operator
            when :==      then value == self.right_operand
            when :ne      then value != self.right_operand
            when :matches then self.right_operand =~ value
            when :gte     then value > self.right_operand
            when :gte     then value >= self.right_operand
            when :lt      then value < self.right_operand
            when :lte     then value <= self.right_operand
            when :size    then value.size == self.right_operand
            when :all     then [*self.right_operand].contains?(value)
            when :in, :nin
              _matches = if value.is_a?(Array)
                [*value].contains?([*self.right_operand])
              else
                [*self.right_operand].include?(value)
              end
              self.operator == :in ? _matches : !_matches
            else
              raise UnknownConditionInScope.new("#{self.operator} is unknown or not implemented.")
            end
          end

          def to_s
            "#{name} #{operator} #{self.right_operand.inspect}"
          end

          protected

          def decode_operator_based_on_name
            if name =~ /^([a-z0-9_-]+)\.(#{OPERATORS.join('|')})$/
              self.name     = $1.to_sym
              self.operator = $2.to_sym
            end

            if self.right_operand.is_a?(Regexp)
              self.operator = :matches
            end
          end

          def decode_operator_based_on_value(value)
            case value
            when Array
              self.operator = :in if self.operator == :==
            end
          end

        end

      end
    end
  end
end