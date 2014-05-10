module Xrc
  class Connection
    class TslConnector
      def self.connect(*args)
        new(*args).connect
      end

      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def connect
        ssl_socket.connect
      end

      private

      def ssl_socket
        ssl_socket = Socket.new(socket, context)
        ssl_socket.sync_close = true
        ssl_socket
      end

      def socket
        options[:socket]
      end

      def context
        context = OpenSSL::SSL::SSLContext.new
        context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        context
      end
    end
  end
end
