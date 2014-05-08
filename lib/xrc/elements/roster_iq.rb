module Xrc
  module Elements
    class RosterIq < REXML::Element
      def initialize
        super("iq")
        query = REXML::Element.new("query")
        query.add_namespace(Client::ROSTER_NAMESPACE)
        add_attributes("type" => "get")
        add(query)
      end
    end
  end
end
