require_relative  'concerns/api_concern'
require_relative  'concerns/deploy_file_concern'
require 'active_support/inflector'

module Locomotive::Wagon
  class DeleteCommand < Struct.new(:env, :path, :resource, :slug)

    include ApiConcern
    include DeployFileConcern

    RESOURCES = %w(page content_type snippet theme_asset translation content_asset).freeze

    # @param [ String ] env The environment to delete from
    # @param [ String ] path The path to a wagon site to delete from
    # @param [ String ] resource The resource type to delete.  @see RESOURCES
    # @param [ String ] slug The id of the resource entry to delete
    def self.delete(*args)
      new(*args).delete
    end

    # @raise [ ArgumentError ] unless the given resources is in RESOURCES
    def delete
      if RESOURCES.include?(resource)
        api_client.send(resource_method).destroy(slug)
      else
        raise ArgumentError, "Resource must be one of #{RESOURCES.join(?,)}"
      end
    end

    private

    def resource_method
      @resource_method ||= resource.pluralize
    end

    def current_site
      @current_site ||= api_client.current_site
    end

    def api_client
      @api_client ||= api_site_client(connection_information_from_env_and_path)
    end

  end
end
