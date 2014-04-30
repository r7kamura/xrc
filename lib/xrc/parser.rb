require "rexml/parsers/sax2parser"

module Xrc
  class Parser < REXML::Parsers::SAX2Parser
    EVENTS = [
      :cdata,
      :characters,
      :end_document,
      :end_element,
      :start_element,
    ]

    attr_reader :reader

    def initialize(*args)
      super
      bind
    end

    private

    def bind
      EVENTS.each do |event|
        listen(event) do |*args|
          send(event, *args)
        end
      end
    end

    def cdata(text)
      puts "#{self.class}##{__method__}(#{text.inspect})"
    end

    def characters(text)
      puts "#{self.class}##{__method__}(#{text.inspect})"
    end

    def end_document
      puts "#{self.class}##{__method__}"
    end

    def end_element(uri, localname, qname)
      puts "#{self.class}##{__method__}(#{uri.inspect}, #{localname.inspect}, #{qname.inspect})"
    end

    def start_element(uri, localname, qname, attributes)
      puts "#{self.class}##{__method__}(#{uri.inspect}, #{localname.inspect}, #{qname.inspect}, #{attributes.inspect})"
    end
  end
end
