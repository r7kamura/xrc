module Xrc
  class MessageBuilder
    # Builds a Message object from a REXML::Element.
    # @param [REXML::Element] element A message element
    # @return [Xrc::Messages::Base] An ancestor of Xrc::Messages::Base instance
    def self.build(element)
      new(element).build
    end

    # @param [REXML::Element] element A message element
    def initialize(element)
      @element = element
    end

    def build
      message_class.new(@element)
    end

    private

    def message_class
      case
      when has_room_message?
        Messages::RoomMessage
      when has_private_message?
        Messages::PrivateMessage
      when has_subject?
        Messages::Subject
      when has_invite?
        Messages::Invite
      else
        Messages::Null
      end
    end

    def has_room_message?
      has_groupchat_type? && has_body?
    end

    def has_private_message?
      has_chat_type? && has_body?
    end

    def has_chat_type?
      type == "chat"
    end

    def has_groupchat_type?
      type == "groupchat"
    end

    def has_body?
      !!@element.elements["body"]
    end

    def has_subject?
      !!@element.elements["subject"]
    end

    def has_invite?
      !!@element.elements["x/invite"]
    end

    def type
      @element.attributes["type"].to_s
    end
  end
end
