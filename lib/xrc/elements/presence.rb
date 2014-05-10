module Xrc
  module Elements
    class Presence < REXML::Element
      def initialize
        super("presence")
      end
    end
  end
end
