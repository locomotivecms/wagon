require 'psych'
require 'stringio'

# Public: A Psych extension to enable choosing output styles for specific
# objects.
#
# Thanks to Tenderlove for help in <http://stackoverflow.com/q/9640277/11687>
#
# Examples
#
#   data = {
#     response: { body: StyledYAML.literal(json_string), status: 200 },
#     person: StyledYAML.inline({ 'name' => 'Stevie', 'age' => 12 }),
#     array: StyledYAML.inline(%w[ apples bananas oranges ])
#   }
#
#   StyledYAML.dump data, $stdout
#
module StyledYAML
  # Tag strings to be output using literal style
  def self.literal obj
    obj.extend LiteralScalar
    return obj
  end

  # http://www.yaml.org/spec/1.2/spec.html#id2795688
  module LiteralScalar
    def yaml_style() Psych::Nodes::Scalar::LITERAL end
  end

  # Tag Hashes or Arrays to be output all on one line
  def self.inline obj
    case obj
    when Hash  then obj.extend FlowMapping
    when Array then obj.extend FlowSequence
    else
      warn "#{self}: unrecognized type to inline (#{obj.class.name})"
    end
    return obj
  end

  # http://www.yaml.org/spec/1.2/spec.html#id2790832
  module FlowMapping
    def yaml_style() Psych::Nodes::Mapping::FLOW end
  end

  # http://www.yaml.org/spec/1.2/spec.html#id2790320
  module FlowSequence
    def yaml_style() Psych::Nodes::Sequence::FLOW end
  end

  # Custom tree builder class to recognize scalars tagged with `yaml_style`
  class TreeBuilder < Psych::TreeBuilder
    attr_writer :next_sequence_or_mapping_style

    def initialize(*args)
      super
      @next_sequence_or_mapping_style = nil
    end

    def next_sequence_or_mapping_style default_style
      style = @next_sequence_or_mapping_style || default_style
      @next_sequence_or_mapping_style = nil
      style
    end

    def scalar value, anchor, tag, plain, quoted, style
      if style_any?(style) and value.respond_to?(:yaml_style) and style = value.yaml_style
        if style_literal? style
          plain = false
          quoted = true
        end
      end
      super
    end

    def style_any?(style) Psych::Nodes::Scalar::ANY == style end

    def style_literal?(style) Psych::Nodes::Scalar::LITERAL == style end

    %w[sequence mapping].each do |type|
      class_eval <<-RUBY
        def start_#{type}(anchor, tag, implicit, style)
          style = next_sequence_or_mapping_style(style)
          super
        end
      RUBY
    end
  end

  # Custom tree class to handle Hashes and Arrays tagged with `yaml_style`
  class YAMLTree < Psych::Visitors::YAMLTree
    %w[Hash Array Psych_Set Psych_Omap].each do |klass|
      class_eval <<-RUBY
        def visit_#{klass} o
          if o.respond_to? :yaml_style
            @emitter.next_sequence_or_mapping_style = o.yaml_style
          end
          super
        end
      RUBY
    end
  end

  # A Psych.dump alternative that uses the custom TreeBuilder
  def self.dump obj, io = nil, options = {}
    real_io = io || StringIO.new(''.encode('utf-8'))
    visitor = YAMLTree.new(options, TreeBuilder.new)
    visitor << obj
    ast = visitor.tree

    begin
      ast.yaml real_io
    rescue
      # The `yaml` method was introduced in later versions, so fall back to
      # constructing a visitor
      Psych::Visitors::Emitter.new(real_io).accept ast
    end

    io ? io : real_io.string
  end
end
