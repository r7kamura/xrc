module Xrc
  module Elements
    class Join < Presence
      def initialize(options)
        super()
        attributes["from"] = options[:from]
        attributes["to"] = options[:to]
        add(x)
      end

      private

      def x
        element = REXML::Element.new("x")
        element.add_namespace("http://jabber.org/protocol/muc")
        element
      end
    end
  end
end
