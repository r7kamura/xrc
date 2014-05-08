module Xrc
  module Elements
    class Session < REXML::Element
      def initialize
        super("iq")
        session = REXML::Element.new("session")
        session.add_namespace(Client::SESSION_NAMESPACE)
        add_attributes("type" => "set")
        add(session)
      end
    end
  end
end
