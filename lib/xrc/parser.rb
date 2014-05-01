require "rexml/document"
require "rexml/element"
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

    attr_accessor :current

    attr_reader :options

    def initialize(socket, options = {})
      super(socket)
      @options = options
      bind
    end

    private

    def client
      options[:client]
    end

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
      consume if has_current? && !has_parent?
      pop
    end

    def start_element(uri, localname, qname, attributes)
      if qname != "stream:stream"
        element = REXML::Element.new(qname)
        element.add_attributes(attributes)
        push(element)
      end
    end

    def push(element)
      if current
        self.current = current.add_element(element)
      else
        self.current = element
      end
    end

    def pop
      if current
        self.current = current.parent
      end
    end

    def consume
      client.receive(current)
    end

    def has_current?
      !!current
    end

    def has_parent?
      !current.parent.nil?
    end
  end
end
