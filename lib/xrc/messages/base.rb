module Xrc
  module Messages
    class Base
      # @return [REXML::Element] Raw element object
      attr_reader :element

      # @param [REXML::Element] element A message element
      def initialize(element)
        @element = element
      end

      # Returns a JID of message sender
      # @return [String]
      # @example
      #   message.from #=> "alice@example.com"
      def from
        @element.attribute("from").to_s
      end

      # Returns a JID of message address
      # @return [String]
      # @example
      #   message.to #=> "bob@example.com"
      def to
        @element.attribute("to").to_s
      end

      # Returns the type of the message
      # @return [String]
      # @example
      #   message.type #=> "groupchat"
      def type
        @element.attribute("type").to_s
      end

      # @return [true, false] True if given message includes delay element
      # @note See XEP-0203 for more details about Delayed Delivery
      def delayed?
        !!@element.elements["delay"]
      end
    end
  end
end
