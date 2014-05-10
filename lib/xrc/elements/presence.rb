module Xrc
  module Elements
    class Presence < REXML::Element
      attr_reader :options

      def initialize(options = {})
        super("presence")
        @options = options
        attributes["from"] = from if from
        attributes["to"] = to if to
      end

      private

      def from
        options[:from]
      end

      def to
        options[:to]
      end
    end
  end
end
