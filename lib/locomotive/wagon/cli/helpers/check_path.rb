module Locomotive
  module Wagon
    module CLI
      module Helpers
        module CheckPath
          protected

          # Check if the path given in option ('.' by default) points to a LocomotiveCMS
          # site. It is also possible to pass a path other than the one from the options.
          #
          # @param [ String ] path The optional path of the site instead of options['path']
          #
          # @return [ String ] The fullpath to the LocomotiveCMS site or nil if it is not a valid site.
          #
          def check_path!(path = nil)
            path ||= options['path']

            path = path == '.' ? Dir.pwd : File.expand_path(path)

            (File.exists?(File.join(path, 'config', 'site.yml')) ? path : nil).tap do |_path|
              if _path.nil?
                say 'The path does not point to a LocomotiveCMS site', :red
              end
            end
          end
        end
      end
    end
  end
end