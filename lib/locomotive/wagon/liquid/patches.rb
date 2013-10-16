module Liquid

  class Drop

    def mounting_point
      @context.registers[:mounting_point]
    end

    def site
      @context.registers[:site]
    end

  end

  class Template

    # creates a new <tt>Template</tt> object from liquid source code
    def parse_with_utf8(source, context = {})
      if RUBY_VERSION =~ /1\.9/
        source = source.force_encoding('UTF-8') if source.present?
      end
      self.parse_without_utf8(source, context)
    end

    alias_method_chain :parse, :utf8

  end

  module StandardFilters

    private

    def to_number(obj)
      case obj
      when Numeric
        obj
      when String
        (obj.strip =~ /^\d+\.\d+$/) ? obj.to_f : obj.to_i
      when DateTime, Date, Time
        obj.to_time.to_i
      else
        0
      end
    end
  end

end
