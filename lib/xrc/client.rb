module Xrc
  class Client
    DEFAULT_PORT = 5222

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def run
      connect
      wait
    end

    def connect
      socket
    end

    def wait
      parser.parse
    end

    def parser
      @parser ||= Parser.new(socket)
    end

    def jid
      @jid ||= Jid.new(options[:jid])
    end

    def port
      options[:port] || DEFAULT_PORT
    end

    def socket
      @socket ||= connector.connect
    end

    private

    def connector
      Connector.new(domain: jid.domain, port: port)
    end
  end
end
