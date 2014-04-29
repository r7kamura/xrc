module Xrc
  class Client
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    # TODO
    def connect
    end

    def jid
      @jid ||= Jid.new(options[:jid])
    end
  end
end
