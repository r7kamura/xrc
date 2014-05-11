module Xrc
  module Elements
    class Roster < REXML::Element
      def initialize
        super("iq")
        query = REXML::Element.new("query")
        query.add_namespace(Namespaces::ROSTER)
        add_attributes("type" => "get")
        add(query)
      end
    end
  end
end
