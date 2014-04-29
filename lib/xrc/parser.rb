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
    end

    def characters(text)
    end

    def end_document
    end

    def end_element(uri, localname, qname)
    end

    def start_element(uri, localname, qname, attributes)
    end
  end
end
