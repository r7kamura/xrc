module Xrc
  class Jid
    PATTERN = /\A(?:([^@]*)@)??([^@\/]*)(?:\/(.*?))?\z/

    attr_writer :node, :domain, :resource

    attr_reader :raw

    # @param [String] raw Jabber ID
    # @example
    #   Xrc::Jid.new("alice@example.com/bot")
    def initialize(raw)
      @raw = raw
    end

    # @return [String] Node section (e.g. alice in alice@example.com/bot)
    def node
      @node ||= sections[0]
    end

    # @return [String] Domain section (e.g. example.com in alice@example.com/bot)
    def domain
      @domain ||= sections[1]
    end

    # @return [String, nil] Resource section, which can be omitted (e.g. bot in alice@example.com/bot)
    def resource
      @resource ||= sections[2]
    end

    # @return [String] Jabber ID without resource section
    def strip
      "#{node}@#{domain}"
    end

    # @return [String] Jabber ID, including resource section if any
    def to_s
      str = strip
      str << "/#{resource}" if resource
      str
    end

    # @return [true, false] True if given Jabber ID is same with self Jabber ID
    def ==(jid)
      jid = Jid.new(jid) unless jid.is_a?(Jid)
      to_s == jid.to_s || strip == jid.strip
    end

    private

    def sections
      @sections ||= raw.scan(PATTERN).first
    end
  end
end
