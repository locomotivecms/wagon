require_relative 'helpers/check_path'

module Locomotive
  module Wagon
    module CLI
      class Generate < Thor
        include Helpers::CheckPath

        class_option :path, aliases: '-p', type: :string, default: '.', optional: true, desc: 'if your LocomotiveCMS site is not in the current path'

        desc 'generate RESOURCE ARGUMENTS', 'Generates a content_type, page, or snippet'
        long_desc <<-LONGDESC
          Generates a content_type, page, or snippet

          RESOURCE can be set to content_type, page, or snippet.

          Use wagon generate help [RESOURCE] for usage information and examples.
        LONGDESC
        subcommand 'generate', Generate

        desc 'content_type SLUG FIELDS', 'Creates a content type with the specified slug and fields.'
        long_desc <<-LONGDESC
          Creates a content type with the specified slug and fields.

          SLUG should be plural, lowercase, and underscored.

          FIELDS format: field_1[:TYPE][:REQUIRED] field_2[:TYPE][:REQUIRED] ...

          TYPE values: string, text, integer, float, boolean, email, date, date_time, file, tags, select, belongs_to, has_many, or many_to_many. Default is string.

          To require a field, set REQUIRED to true. The first field is required by default.

          Examples:

            * wagon generate content_type posts title published_at:date_time:true body:text

            * wagon generate content_type products title price:float photo:file category:belongs_to:true
        LONGDESC
        def content_type(name, *fields)
          say('The fields are missing', :red) and return false if fields.empty?

          if check_path!
            Locomotive::Wagon.generate :content_type, name, self.options['path'], fields
          end
        end

        desc 'page FULLPATH', 'Create a page. No need to pass an extension to the FULLPATH arg'
        long_desc <<-LONGDESC
          Create a page. The generator will ask for the extension (liquid or haml) and also
          if the page is localized or not.

          Examples:

            * wagon generate page contact

            * wagon generate page about_us/me
        LONGDESC
        def page(fullpath)
          if path = check_path!
            locales = self.site_config(path)['locales']
            Locomotive::Wagon.generate :page, fullpath, self.options['path'], locales
          end
        end

        desc 'snippet SLUG', 'Create a snippet'
        long_desc <<-LONGDESC
          Create a snippet. The generator will ask for the extension (liquid or haml) and also
          if the snippet is localized or not.

          Example:

            * wagon generate snippet footer
        LONGDESC
        def snippet(slug)
          if path = check_path!
            locales = self.site_config(path)['locales']
            Locomotive::Wagon.generate :snippet, slug, self.options['path'], locales
          end
        end

        protected

        # Read the YAML config file of a LocomotiveCMS site.
        # The path should be returned by the check_path! method first.
        #
        # @param [ String ] path The full path to a LocomotiveCMS site.
        #
        # @return [ Hash ] The site
        #
        def site_config(path = nil)
          YAML.load_file(File.join(path, 'config', 'site.yml'))
        end
      end
    end
  end
end