module Xrc
  class Connection
    attr_reader :block, :domain, :port, :socket

    def initialize(options, &block)
      @domain = options[:domain]
      @port = options[:port]
      @block = block
    end

    def connect
      @socket = Connector.connect(domain: domain, port: port)
      start
    end

    def encrypt
      @socket = TslConnector.connect(socket: socket)
      start
    end

    def open
      write Elements::Stream.new(domain: domain)
    end

    def write(object)
      socket << object.to_s
    end

    log :write do |element|
      "Posting:\n" + element.to_s.indent(2)
    end

    private

    def start
      open
      parse
    end

    def parse
      Parser.new(socket: socket, &block).parse
    end
  end
end
