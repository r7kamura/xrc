module Xrc
  class Jid
    PATTERN = /\A(?:([^@]*)@)??([^@\/]*)(?:\/(.*?))?\z/

    attr_reader :raw

    def initialize(raw)
      @raw = raw
    end

    def node
      sections[0]
    end

    def domain
      sections[1]
    end

    def resource
      sections[2]
    end

    def strip
      "#{node}@#{domain}"
    end

    def to_s
      str = strip
      str << "/#{resource}" if resource
      str
    end

    private

    def sections
      @sections ||= raw.scan(PATTERN).first
    end
  end
end
