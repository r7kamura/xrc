module Xrc
  class Client
    DEFAULT_PORT = 5222

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def run
      connect
      start
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
      Connector.new(domain: domain, port: port)
    end

    def domain
      jid.domain
    end

    def start
      socket << start_message
    end

    def start_message
      %W[
        <stream:stream
        xmlns:stream="http://etherx.jabber.org/streams"
        xmlns="jabber:client"
        to="#{domain}"
        xml:lang="en"
        version="1.0">
      ].join(" ")
    end
  end
end
