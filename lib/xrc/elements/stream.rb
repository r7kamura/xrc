module Xrc
  module Elements
    class Stream
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def to_s
        %W[
          <stream:stream
          xmlns:stream="http://etherx.jabber.org/streams"
          xmlns="jabber:client"
          to="#{options[:domain]}"
          xml:lang="en"
          version="1.0">
        ].join(" ")
      end
    end
  end
end
