require 'locomotive/common'

require_relative '../tools/styled_yaml'

require_relative 'loggers/sync_logger'

require_relative_all  'concerns'
require_relative      'sync_sub_commands/concerns/base_concern'

require_relative      'pull_sub_commands/pull_base_command'
require_relative_all  'pull_sub_commands'
require_relative_all  'sync_sub_commands'

module Locomotive::Wagon

  class SyncCommand < Struct.new(:env, :path, :options, :shell)

    RESOURCES = %w(site pages content_entries translations).freeze

    include ApiConcern
    include DeployFileConcern
    include InstrumentationConcern
    include SpinnerConcern

    def self.sync(env, path, options, shell)
      self.new(env, path, options, shell).sync
    end

    def sync
      if options[:verbose]
        SyncLogger.new
        _sync
      else
        show_wait_spinner('Syncing content...') { _sync }
      end
    end

    private

    def _sync
      api_client = api_site_client(connection_information)

      site = api_client.current_site.get

      each_resource do |klass|
        klass.sync(api_client, site, path, env)
      end

      print_result_message
    end

    def each_resource
      RESOURCES.each do |name|
        next if !options[:resources].blank? && !options[:resources].include?(name)

        klass = "Locomotive::Wagon::Sync#{name.camelcase}Command".constantize

        yield klass
      end
    end

    def connection_information
      read_deploy_settings(self.env, self.path)
    end

    def print_result_message
      shell.say "\n\nThe content of your local Wagon site has been updated.", :green
      true
    end

  end

end
