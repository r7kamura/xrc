module Xrc
  module Messages
    class RoomMessage < Base
      # Returns the message body (e.g. Hello)
      # @return [String]
      # @example
      #   message.body #=> "Hello"
      def body
        @element.elements["body/text()"]
      end

      # Returns this message in Hash format
      # @return [Hash]
      # @example
      #   message.to_hash #=> {
      #     :body => "bob@example.com",
      #     :from => "alice@example.com",
      #     :to   => "bob@example.com",
      #   }
      def to_hash
        {
          body: body,
          from: from,
          to: to,
        }
      end
    end
  end
end
