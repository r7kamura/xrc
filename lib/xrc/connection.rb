module Xrc
  class Connection
    attr_reader :domain, :port, :socket

    def initialize(options)
      @domain = options[:domain]
      @port = options[:port]
    end

    def connect
      @socket = Connector.connect(domain: domain, port: port)
    end

    def encrypt
      @socket = TslConnector.connect(socket: socket)
    end

    def write(object)
      socket << object.to_s
    end

    log :write do |element|
      "Posting:\n" + element.to_s.indent(2)
    end
  end
end
