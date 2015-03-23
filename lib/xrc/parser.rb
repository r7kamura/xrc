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

    attr_reader :block, :options

    def initialize(options, &block)
      super(options[:socket])
      @block = block
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
      if current
        cdata = REXML::CData.new(text)
        current.add(cdata)
      end
    end

    def characters(text)
      if current
        text = REXML::Text.new(to_safe(text), current.whitespace, nil, true)
        current.add(text)
      end
    end

    def to_safe(text)
      text.chars.map do |c|
        case c.ord
        when *REXML::Text::VALID_CHAR
          c
        else
          ""
        end
      end.join
    end

    def end_document
    end

    def end_element(uri, localname, qname)
      consume if has_current? && !has_parent?
      pop
    end

    def start_element(uri, localname, qname, attributes)
      element = REXML::Element.new(qname)
      element.add_attributes(attributes)
      if qname == "stream:stream"
        consume(element)
      else
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

    def consume(element = current)
      block.call(element)
    end

    def has_current?
      !!current
    end

    def has_parent?
      !current.parent.nil?
    end
  end
end
