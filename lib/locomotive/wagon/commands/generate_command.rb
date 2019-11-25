module Locomotive::Wagon

  class GenerateCommand < Struct.new(:name, :args, :options)

    def self.generate(name, args, options)
      new(name, args, options).generate
    end

    def generate
      Locomotive::Wagon.require_misc_gems
      
      generator = generator_klass.new(args, options, { behavior: :skip })
      generator.destination_root = args.last
      generator.force_color_if_asked(options)
      generator.invoke_all
    end

    private

    def generator_klass
      lib = "locomotive/wagon/generators/#{name}"
      require lib

      lib.camelize.constantize
    end

  end

end
