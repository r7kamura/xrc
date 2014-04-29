require "socket"

module Xrc
  class Client
    DEFAULT_PORT = 5222

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def connect
      socket
    end

    def jid
      @jid ||= Jid.new(options[:jid])
    end

    def hosts
      HostsResolver.call(jid.domain)
    end

    def port
      options[:port] || DEFAULT_PORT
    end

    def socket
      hosts.find do |host|
        begin
          break TCPSocket.new(host, port)
        rescue SocketError, Errno::ECONNREFUSED
        end
      end
    end
  end
end
