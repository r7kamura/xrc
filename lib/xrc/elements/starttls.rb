module Xrc
  module Elements
    class Starttls < REXML::Element
      def initialize
        super("starttls")
        add_namespace(Client::TLS_NAMESPACE)
      end
    end
  end
end
