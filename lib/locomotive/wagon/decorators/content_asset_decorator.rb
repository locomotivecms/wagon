module Locomotive
  module Wagon

    class ContentAssetDecorator < Struct.new(:filepath)

      include ToHashConcern

      def __attributes__
        %i(source)
      end

      def source
        Locomotive::Coal::UploadIO.new(_readfile(filepath), nil, filename)
      end

      def checksum
        Digest::MD5.hexdigest(_readfile(filepath) { |io| io.read })
      end

      def filename
        File.basename(filepath)
      end

      private
      
      def _readfile(path, &block)
        File.open(path, 'rb', &block)
      end
    end

  end

end

