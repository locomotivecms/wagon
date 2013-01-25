module Locomotive
  module Builder
    class Dragonfly

      attr_accessor :path, :enabled

      def enabled?
        !!self.enabled
      end

      def resize_url(source, resize_string)
        _source = (case source
        when String then source
        when Hash   then source['url'] || source[:url]
        else
          source.try(:url)
        end)

        if _source.blank?
          LocomotiveEditor::Logger.error "Unable to resize on the fly: #{source.inspect}"
          return
        end

        return _source unless self.enabled?

        if _source =~ /^http/
          file = self.class.app.fetch_url(_source)
        else
          file = self.class.app.fetch_file(File.join(self.path, 'public', _source))
        end

        file.process(:thumb, resize_string).url
      end

      def self.app
        ::Dragonfly[:images]
      end


      def self.instance
        @@instance ||= new
      end

      def self.setup!(path)
        self.instance.path    = path
        self.instance.enabled = false

        begin
          require 'rack/cache'
          require 'RMagick'
          require 'dragonfly'

          ## initialize Dragonfly ##
          app = ::Dragonfly[:images].configure_with(:imagemagick)

          ## configure it ##
          ::Dragonfly[:images].configure do |c|
            convert = `which convert`.strip.presence || '/usr/local/bin/convert'
            c.convert_command  = convert
            c.identify_command = convert

            c.allow_fetch_url  = true
            c.allow_fetch_file = true

            c.url_format = '/images/dynamic/:job/:basename.:format'
          end

          puts 'Dragonfly enabled'

          self.instance.enabled = true
        rescue Exception => e
          puts %{
  \tIf you want to take full benefits of all the features in the LocomotiveEditor, we recommend you to install ImageMagick and RMagick.
  \tCheck out the documentation here: http://doc.locomotivecms.com/editor/installation.}

          puts 'Dragonfly disabled'
        end
      end

    end
  end
end