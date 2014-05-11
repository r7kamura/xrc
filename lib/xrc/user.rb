module Xrc
  class User
    # @option attributes [String] :jid JID
    # @option attributes [String] :mention_name Mention name
    # @option attributes [String] :name Full name
    # @example
    #   Xrc::Client.new(jid: "alice@example.com", mention_name: "alice", name: "Alice Liddel")
    def initialize(attributes)
      @attributes = attributes
    end

    # @return [Xrc::Jid] JID represented in a Xrc::Jid object
    def jid
      @jid ||= Jid.new(@attributes[:jid])
    end

    # @return [String] Mention name
    def mention_name
      @attributes[:mention_name]
    end

    # @return [String] Full name
    def name
      @attributes[:name]
    end
  end
end
