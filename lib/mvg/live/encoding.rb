module MVG
  class Live
    module Encoding
      def to_utf8(string)
        string.encode("UTF-8")
      end

      def to_encoding(string)
        string.encode @encoding
      end
    end
  end
end
