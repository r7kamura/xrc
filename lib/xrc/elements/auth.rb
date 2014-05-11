module Xrc
  module Elements
    class Auth < REXML::Element
      attr_reader :options

      def initialize(options = {})
        super("auth")
        @options = options
        add_sasl_namespace
        add_plain_mechanism_attribute
        add_credentials_text
      end

      private

      def jid
        options[:jid]
      end

      def password
        options[:password]
      end

      def plain_credentials
        "#{jid.strip}\x00#{jid.node}\x00#{password}"
      end

      def add_sasl_namespace
        add_namespace(Namespaces::SASL)
      end

      def add_plain_mechanism_attribute
        attributes["mechanism"] = "PLAIN"
      end

      def add_credentials_text
        self.text = Base64.strict_encode64(plain_credentials)
      end
    end
  end
end
