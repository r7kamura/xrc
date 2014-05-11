module Xrc
  module Messages
    class Base
      # @return [REXML::Element] Raw element object
      attr_reader :element

      # @param [REXML::Element] element A message element
      def initialize(element)
        @element = element
      end

      # Returns a JID of message sender (e.g. alice@example.com)
      # @return [String]
      # @example
      #   message.from #=> "alice@example.com"
      def from
        @element.attribute("from").to_s
      end

      # Returns a JID of message address (e.g. bob@example.com)
      # @return [String]
      # @example
      #   message.to #=> "bob@example.com"
      def to
        @element.attribute("to").to_s
      end
    end
  end
end
