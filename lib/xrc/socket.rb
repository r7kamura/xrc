module Xrc
  class Socket < OpenSSL::SSL::SSLSocket
    def sysread(*args)
      super.force_encoding(Encoding::UTF_8)
    end
  end
end
