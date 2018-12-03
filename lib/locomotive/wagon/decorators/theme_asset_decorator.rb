module Locomotive
  module Wagon

    class ThemeAssetDecorator < SimpleDelegator

      include ToHashConcern

      EXTENSIONS_TABLE = {
        '.scss'       => '.css',
        '.css.scss'   => '.css',
        '.sass'       => '.css',
        '.css.sass'   => '.css',
        '.less'       => '.css',
        '.css.less'   => '.css',
        '.coffee'     => '.js',
        '.js.coffee'  => '.js'
      }.freeze

      def __attributes__
        %i(source folder checksum)
      end

      def source
        Locomotive::Coal::UploadIO.new(_readfile(filepath), nil, realname)
      end

      def priority
        stylesheet_or_javascript? ? 100 : 0
      end

      def stylesheet_or_javascript?
        File.extname(realname) =~ /^\.(css|scss|less|js|coffee)$/
      end

      def checksum
        Digest::MD5.hexdigest(_readfile(filepath) { |io| io.read })
      end

      # - memoize it because it will not change even if we change the filepath (or source)
      # - we keep the first extension and drop the others (.coffee, .scss, ...etc)
      def realname
        return @realname if @realname

        filename = File.basename(filepath)

        @realname = _realname(filename, 2) || _realname(filename, 1) || filename
      end

      def relative_url
        "#{folder.gsub('\\', '/')}/#{realname}"
      end

      def short_relative_url
        relative_url[/^(javascripts|stylesheets|fonts)\/(.*)$/, 2]
      end

      def filepath
        __getobj__.source
      end

      def filepath=(path)
        __getobj__[:source] = path
      end

      private

      def _realname(filename, length)
        extension = '.' + filename.split('.').last(length).join('.')

        if new_extension = EXTENSIONS_TABLE[extension]
          File.basename(filename, extension) + new_extension
        end
      end

      def _readfile(path, &block)
        File.open(path, 'rb', &block)
      end

    end

  end
end
