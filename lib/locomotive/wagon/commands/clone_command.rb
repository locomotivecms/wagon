module Locomotive::Wagon

  class CloneCommand < Struct.new(:name, :path, :options, :shell)

    def self.clone(name, path, options, shell)
      new(name, path, options, shell).clone
    end

    def clone
      # TODO
    end

  end

end
