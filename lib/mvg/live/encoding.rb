if '1.9'.respond_to?(:encode)
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

else
  # upgrade to 1.9.3 or gtfo. srsly!
  require 'iconv'

  module MVG
    class Live
      module Encoding
        def to_utf8(string)
          Iconv.iconv("utf8", @encoding, string).join
        end

        def to_encoding(string)
          Iconv.iconv(@encoding, "utf8", string).join
        end
      end
    end
  end
end
