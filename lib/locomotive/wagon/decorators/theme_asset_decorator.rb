module Locomotive
  module Wagon

    class ThemeAssetDecorator < SimpleDelegator

      include ToHashConcern

      def __attributes__
        %i(source folder checksum)
      end

      def source
        Locomotive::Coal::UploadIO.new(filepath, nil, realname)
      end

      def priority
        stylesheet_or_javascript? ? 100 : 0
      end

      def stylesheet_or_javascript?
        File.extname(realname) =~ /^(\.css|\.js)/
      end

      def checksum
        Digest::MD5.hexdigest(File.read(filepath))
      end

      def relative_url
        "#{folder.gsub('\\', '/')}/#{realname}"
      end

      def short_relative_url
        relative_url[/^(javascripts|stylesheets|fonts)\/(.*)$/, 2]
      end

      def realname
        # - memoize it because it will not change even if we change the filepath (or source)
        # - we keep the first extension and drop the others (.coffee, .scss, ...etc)
        @realname ||= if Sprockets.engine_extensions.include?(File.extname(filepath))
          File.basename(filepath).split('.')[0..-2].join('.')
        else
          File.basename(filepath)
        end
      end

      def filepath
        __getobj__.source
      end

      def filepath=(path)
        __getobj__[:source] = path
      end

    end

  end
end
