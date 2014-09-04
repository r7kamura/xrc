module Xrc
  module Messages
    class Invite < Base
      def room_name
        @element.elements["//name/text()"].to_s
      end
    end
  end
end
