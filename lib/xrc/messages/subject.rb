module Xrc
  module Messages
    class Subject < Base
      # Returns the message subject (e.g. Room1)
      # @return [String]
      # @example
      #   message.subject #=> "Room1"
      def subject
        @element.elements["subject/text()"].to_s
      end

      # Returns this message in Hash format
      # @return [Hash]
      # @example
      #   message.to_hash #=> {
      #     :from    => "alice@example.com",
      #     :subject => "Room1",
      #     :to      => "bob@example.com",
      #   }
      def to_hash
        {
          from: from,
          to: to,
          subject: subject,
        }
      end
    end
  end
end
