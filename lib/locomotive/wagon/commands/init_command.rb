module Locomotive::Wagon

  class InitCommand < Struct.new(:generator_klass, :args, :options)

    def self.generate(klass, args, options)
      new(klass, args, options).generate
    end

    def generate
      args, opts = Thor::Options.split(self.args)

      generator = generator_klass.new(args, opts, {})
      generator.force_color_if_asked(options)
      generator.invoke_all
    end

  end

end
