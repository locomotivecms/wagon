require 'open-uri'
require 'zip/zipfilesystem'

module Locomotive
  module Wagon
    module Generators
      module Site

        class Unzip < Base

          class_option :location, type: :string, default: nil, required: false, desc: 'Location of the zip file'

          @@source_root = nil

          def prepare
            remove_file join('tmp')
            empty_directory join('tmp')
          end

          def ask_for_location
            @location = options[:location] || ask('What is the location (on the filesystem or url) of the zip file ?')
            raise GeneratorException.new('Please enter a location') if @location.blank?
          end

          def download_or_copy
            @template_path = join('tmp', File.basename(@location))

            if @location =~ /^https?:\/\//
              say "downloading...#{@location}"
              create_file @template_path, open(@location).read
            else
              say "copying...#{@location}"
              create_file @template_path, open(@location, 'rb') { |io| io.read }
            end
          end

          def unzip
            say "unzipping...#{@template_path}"

            begin
              Zip::ZipFile.open(@template_path) do |zipfile|
                zipfile.each do |file|
                  next if file.name =~ /^__MACOSX/
                  zipfile.extract(file, join('tmp', file.name))

                  @path = $1 if file.name =~ /(.*)\/config\/site.yml$/
                end
              end
            rescue Exception => e
              raise GeneratorException.new("Unable to unzip the archive")
            end

            raise GeneratorException.new('Not a valid LocomotiveCMS site') if @path.blank?
          end

          def copy_sources
            self.class.source_root = File.expand_path(join('tmp', @path, '/'))
            say "copying files from #{self.class.source_root} / #{self.destination}"
            directory('.', self.destination, { recursive: true })
          end

          def bundle_install
            super
          end

          def self.source_root
            # only way to change the source root from the instance
            @@source_root
          end

          def self.source_root=(value)
            @@source_root = value
          end

          protected

          def join(*args)
            File.join(self.destination, *args)
          end

        end

        Locomotive::Wagon::Generators::Site.register(:unzip, Unzip, %{
          Unzip a local or remote (http, https, ftp) zipped site.
        })
      end
    end
  end
end