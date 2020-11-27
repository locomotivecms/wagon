require_relative  'concerns/api_concern'
require_relative  'concerns/deploy_file_concern'
require 'active_support/inflector'

module Locomotive::Wagon
  class DeleteCommand < Struct.new(:env, :path, :resource, :identifier, :shell)

    include ApiConcern
    include DeployFileConcern

    SITE_RESOURCE     = 'site'
    SINGLE_RESOURCES  = %w(page content_type snippet section translation).freeze
    ALL_RESOURCES     = %w(content_types snippets theme_assets sections translations).freeze

    # @param [ String ] env The environment to delete from
    # @param [ String ] path The path to a wagon site to delete from
    # @param [ String ] resource The resource type to delete.  @see RESOURCES
    # @param [ String ] identifier The id or handle of the resource entry to delete
    def self.delete(*args)
      new(*args).delete
    end

    # @raise [ ArgumentError ] unless the given resources is in SINGLE_RESOURCES or MULTIPLE_RESOURCES
    def delete
      if resource == SITE_RESOURCE
        delete_site
      elsif SINGLE_RESOURCES.include?(resource)
        delete_single
      elsif ALL_RESOURCES.include?(resource)
        delete_all
      else
        raise ArgumentError, "Resource must be one of #{SINGLE_RESOURCES.join(?,)} if you pass an identifier OR be one of #{ALL_RESOURCES.join(?,)} if you want to delete all the items of that resource."
      end
    end

    private

    def delete_site
      if shell.ask('Please, type the handle of your site') == client.options[:handle]
        client.current_site.destroy.tap do |response|
          shell.say "The remote site specified in your #{env} environment has been deleted.", :green
        end
      else
        shell.say 'The delete operation has been cancelled', :red
      end
    end

    def delete_single
      client.send(resource_method).destroy(identifier).tap do |response|
        shell.say "The #{identifier} #{singular_resource_method} has been deleted.", :green
      end
    end

    def delete_all
      client.send(resource_method).destroy_all.tap do |response|
        shell.say "#{response['deletions']} #{resource_method} have been deleted", :green
      end
    end

    def resource_method
      @resource_method ||= resource.pluralize
    end

    def singular_resource_method
      @resource_method.singularize
    end

    def current_site
      @current_site ||= client.current_site
    end

    def client
      @api_site_client ||= api_site_client(connection_information_from_env_and_path)
    end

  end
end
