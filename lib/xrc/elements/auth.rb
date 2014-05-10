module Xrc
  module Elements
    class Auth < REXML::Element
      def initialize(options = {})
        super("auth")
        add_namespace(Client::SASL_NAMESPACE)
        attributes["mechanism"] = "PLAIN"
        self.text = Base64.strict_encode64(options[:credentials])
      end
    end
  end
end
