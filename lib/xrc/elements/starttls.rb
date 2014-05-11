module Xrc
  module Elements
    class Starttls < REXML::Element
      def initialize
        super("starttls")
        add_namespace(Namespaces::TLS)
      end
    end
  end
end
