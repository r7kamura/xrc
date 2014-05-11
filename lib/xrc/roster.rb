module Xrc
  class Roster
    # @param [REXML::Element] element An element of the response of roster requirement
    def initialize(element)
      @element = element
    end

    # Find a Xrc::User object from its JID
    # @param [String] jid JID
    # @return [Xrc::User]
    # @return [nil]
    def [](jid)
      users.find {|user| user.jid == jid }
    end

    private

    def users
      @users ||= @element.elements.collect("query/item") do |item|
        User.new(
          jid: item.attribute("jid").to_s,
          mention_name: item.attribute("mention_name").to_s,
          name: item.attribute("name").to_s,
        )
      end
    end
  end
end
