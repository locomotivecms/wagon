module Locomotive::Wagon

  class SyncSiteCommand < PullSiteCommand

    include Locomotive::Wagon::BaseConcern

    def _sync
      attributes = current_site.attributes.slice('metafields')

      # convert to hash + download assets and use the asset local version
      decode_metafields(attributes)

      # modify the config/site.yml file accordingly
      replace_metafields_in_file(attributes['metafields'])
    end

    protected

    def replace_metafields_in_file(metafields)
      return if metafields.blank?

      content = File.read(File.join(path, 'config', 'site.yml'))

      content.gsub!(/^metafields:\n.+\n\s+.*?\n/m, { 'metafields' => metafields }.to_yaml.to_s.gsub(/\A---\n/, ''))

      File.write(File.join(path, 'config', 'site.yml'), content)
    end

  end

end
