module Xrc
  module Messages
    class Message < Base
      # Returns the message body with unescaping HTML.
      # @return [String]
      # @example
      #   message.body #=> "Hello"
      def body
        CGI.unescape_html(@element.elements["body/text()"].to_s)
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
