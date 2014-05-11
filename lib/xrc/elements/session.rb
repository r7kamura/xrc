module Xrc
  module Elements
    class Session < REXML::Element
      def initialize
        super("iq")
        session = REXML::Element.new("session")
        session.add_namespace(Namespaces::SESSION)
        add_attributes("type" => "set")
        add(session)
      end
    end
  end
end
