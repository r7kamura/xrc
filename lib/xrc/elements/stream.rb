module Xrc
  module Elements
    class Stream
      attr_reader :domain

      def initialize(domain)
        @domain = domain
      end

      def to_s
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
end
