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

    def port
      options[:port] || DEFAULT_PORT
    end

    def socket
      connector.connect
    end

    def connector
      Connector.new(domain: jid.domain, port: port)
    end
  end
end
