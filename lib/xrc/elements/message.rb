module Xrc
  module Elements
    class Message < REXML::Element
      def initialize(options = {})
        super("message")
        attributes["from"] = options[:from]
        attributes["to"] = options[:to]
        attributes["type"] = options[:type]
        body.text = options[:body]
        add(body)
      end

      private

      def body
        @body ||= REXML::Element.new("body")
      end
    end
  end
end
