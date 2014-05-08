module Xrc
  module Elements
    class Bind < REXML::Element
      def initialize(options = {})
        super("iq")
        bind = REXML::Element.new("bind")
        bind.add_namespace(Client::BIND_NAMESPACE)
        if options[:resource]
          resource = REXML::Element.new("resource")
          resource.text = options[:resource]
          bind.add(resource)
        end
        add_attributes("type" => "set")
        add(bind)
      end
    end
  end
end
