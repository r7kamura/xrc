require "socket"

module Xrc
  class Connector
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def connect
      hosts.find do |host|
        begin
          break TCPSocket.new(host, port)
        rescue SocketError, Errno::ECONNREFUSED
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
      HostsResolver.call(domain)
    end
  end
end
