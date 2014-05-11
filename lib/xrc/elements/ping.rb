module Xrc
  module Elements
    class Ping < REXML::Element
      def initialize(options = {})
        super("iq")
        attributes["from"] = options[:from]
        attributes["to"] = options[:to]
        attributes["type"] = "get"
        add(ping)
      end

      private

      def ping
        element = REXML::Element.new("ping")
        element.add_namespace(Namespaces::PING)
        element
      end
    end
  end
end
