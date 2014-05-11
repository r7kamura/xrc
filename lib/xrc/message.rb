# Represents a given message element.
module Xrc
  class Message
    # @return [REXML::Element] Raw element object
    attr_reader :element

    # @param [REXML::Element] element A message element
    # @example
    #   body = REXML::Element.new("body")
    #   body.text = "Hello"
    #   element = REXML::Element.new("message")
    #   element.add_attributes(
    #     "from" => "alice@example.com",
    #     "to"   => "bob@example.com",
    #     "type" => "groupchat",
    #   )
    #   element.add(body)
    #   message = Xrc::Message.new(element)
    def initialize(element)
      @element = element
    end

    # Returns message type (e.g. chat, groupchat, ...)
    # @return [String]
    # @example
    #   message.type #=> "groupchat"
    def type
      @element.attribute("type").to_s
    end

    # Returns a JID of message sender (e.g. alice@example.com)
    # @return [String]
    # @example
    #   message.from #=> "alice@example.com"
    def from
      @element.attribute("from").to_s
    end

    # Returns a JID of message address (e.g. bob@example.com)
    # @return [String]
    # @example
    #   message.to #=> "bob@example.com"
    def to
      @element.attribute("to").to_s
    end

    # Returns the message body (e.g. Hello)
    # @return [nil]
    # @return [String]
    # @example
    #   message.body #=> "Hello"
    def body
      @element.elements["body/text()"].try(:value)
    end

    # Returns the message subject (e.g. Room1)
    # @return [nil]
    # @return [String]
    # @example
    #   message.subject #=> nil
    def subject
      @element.elements["subject/text()"].try(:value)
    end

    # Returns this message in Hash format
    # @return [Hash]
    # @example
    #   message.to_hash #=> {
    #     :body    => "bob@example.com",
    #     :from    => "alice@example.com",
    #     :subject => nil,
    #     :to      => "bob@example.com",
    #     :type    => "groupchat",
    #   }
    def to_hash
      {
        body: body,
        from: from,
        to: to,
        subject: subject,
        type: type,
      }
    end
  end
end
