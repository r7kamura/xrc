module Xrc
  module Elements
    class Presence < REXML::Element
      def initialize(options = {})
        super("presence")
      end
    end
  end
end
