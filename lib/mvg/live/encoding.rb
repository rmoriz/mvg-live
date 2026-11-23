module MVG
  class Live
    module Encoding
      def to_utf8(string)
        string.to_s.encode('UTF-8')
      end

      def to_encoding(string)
        string.to_s.encode(@encoding)
      end
    end
  end
end
