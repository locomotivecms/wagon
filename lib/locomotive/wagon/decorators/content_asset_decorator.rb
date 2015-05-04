module Locomotive
  module Wagon

    class ContentAssetDecorator < Struct.new(:filepath)

      include ToHashConcern

      def __attributes__
        %i(source)
      end

      def source
        Locomotive::Coal::UploadIO.new(filepath, nil, filename)
      end

      def checksum
        Digest::MD5.hexdigest(File.read(filepath))
      end

      def filename
        File.basename(filepath)
      end

    end

  end

end

