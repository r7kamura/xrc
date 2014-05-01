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

    log :connect do
      "Connecting to #{domain}:#{port}"
    end

    def wait
      parser.parse
    end

    log :wait do
      "Waiting for message"
    end

    def parser
      @parser ||= Parser.new(socket, client: self)
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

    # TODO
    def receive(element)
    end

    log :receive do |element|
      "Received #{element}"
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

    log :start do
      "Starting stream"
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
