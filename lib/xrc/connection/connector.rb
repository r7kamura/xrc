module Xrc
  class Connection
    class Connector
      def self.connect(*args)
        new(*args).connect
      end

      attr_reader :options

      def initialize(options)
        @options = options
      end

      def connect
        hosts.find do |host|
          if socket = connect_to(host)
            break socket
          end
        end
      end

      private

      def domain
        options[:domain]
      end

      def port
        options[:port]
      end

      def hosts
        options[:hosts] || HostsResolver.call(domain)
      end

      def connect_to(host)
        TCPSocket.new(host, port)
      rescue SocketError, Errno::ECONNREFUSED => exception
      end
    end
  end
end
