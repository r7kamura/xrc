module Xrc
  class MessageBuilder
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
      when has_subject?
        Messages::Subject
      else
        Messages::Null
      end
    end

    def has_room_message?
      has_groupchat? && has_body?
    end

    def has_groupchat?
      @element.attributes["type"].to_s == "groupchat"
    end

    def has_body?
      !!@element.elements["body"]
    end

    def has_subject?
      !!@element.elements["subject"]
    end
  end
end
