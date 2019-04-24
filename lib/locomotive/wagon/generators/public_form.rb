require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class PublicForm < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :target_path # path to the site

        def create_content_type
          slug = ask("What's the slug of the content type? (ex.: user_messages)")
          @content_type_slug = slug = slug.underscore

          file_path = File.join(content_types_path, slug)

          template "content_type.yml.tt", "#{file_path}.yml", {
            name: slug.humanize,
            slug: slug
          }
        end

        def create_page_form
          slug = ask("What's the slug of your page? (ex.: contact-us)")
          slug = slug.dasherize

          file_path = File.join(pages_path, slug)

          template "page.liquid.tt", "#{file_path}.liquid", {
            title:        slug.humanize,
            handle:       slug.underscore,
            content_type: @content_type_slug
          }
        end

        def add_metafields_schema
          append_to_file 'config/metafields_schema.yml', <<-YAML

google:
  label: Google API Integration
  fields:
    recaptcha_site_key:
      hint: reCAPTCHA - Site key
      type: string
      hint: "Visit: https://developers.google.com/recaptcha/intro"
    recaptcha_secret:
      hint: reCAPTCHA - Secret key
      type: string
          YAML
        end

        def add_metafields
          append_to_file 'config/site.yml', <<-YAML

metafields:
  google:
    recaptcha_site_key: "<GOOGLE SITE KEY>"
    recaptcha_secret: "<GOOGLE SECRET>"
          YAML
        end

        protected

        def content_types_path
          File.join(target_path, 'app', 'content_types')
        end

        def pages_path
          File.join(target_path, 'app', 'views', 'pages')
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'public_form')
        end

      end

    end
  end
end
