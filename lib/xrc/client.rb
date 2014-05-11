module Xrc
  class Client
    DEFAULT_PORT = 5222

    PING_INTERVAL = 60

    # @return [Array] Users information represented in an Array of OpenStructs
    attr_reader :roster

    # @option options [String] :port Port number to connect server (default: 5222)
    # @option options [String] :jid Jabber ID of your account (required)
    # @option options [String] :nickname Pass nickname for the Room (optional)
    # @option options [String] :password Password to connect server (optional)
    # @option options [String] :room_jid Room Jabber ID to join in after authentication (optional)
    # @example
    #   client = Xrc::Client.new(jid: "alice@example.com")
    def initialize(options = {})
      @options = options
    end

    # Connects to the JID's server and waits for message
    # @return [nil] Returns nothing
    def connect
      connection.connect
      nil
    end

    # Registers a callback called when client received a new message from server
    # @yield Executes a given callback in the Client's context
    # @yieldparam element [REXML::Element] Represents a new message
    # @return [Proc] Returns given block
    # @example
    #   client.on_message do |element|
    #     puts "Received #{element}"
    #   end
    #
    def on_message(&block)
      @on_message_block = block
    end

    # Registers a callback called when client received a new XML element from server
    # @yield Executes a given callback in the Client's context
    # @yieldparam element [REXML::Element] Represents a new XML element
    # @return [Proc] Returns given block
    # @example
    #   client.on_event do |element|
    #     puts "Received #{element}"
    #   end
    #
    def on_event(&block)
      @on_event_block = block
    end

    private

    def on_message_block
      @on_message_block ||= ->(element) {}
    end

    def on_event_block
      @on_event_block ||= ->(element) {}
    end

    def on_received(element)
      instance_exec(element, &on_event_block)
      case
      when element.attribute("id") && has_reply_callbacks_to?(element.attribute("id").value)
        on_replied(element)
      when element.name == "message"
        on_message_received(element)
      when element.prefix == "stream" && element.name == "features"
        on_features_received(element)
      when element.name == "proceed" && element.namespace == Namespaces::TLS
        on_tls_proceeded(element)
      when element.name == "success" && element.namespace == Namespaces::SASL
        on_authentication_succeeded(element)
      when element.name == "failure" && element.namespace == Namespaces::SASL
        on_authentication_failed(element)
      end
    end

    def jid
      @jid ||= Jid.new(@options[:jid])
    end

    def password
      @options[:password]
    end

    def nickname
      @options[:nickname]
    end

    def port
      @options[:port] || DEFAULT_PORT
    end

    def room_jid
      Jid.new("#{@options[:room_jid]}") if @options[:room_jid]
    end

    def connection
      @connection ||= Connection.new(domain: jid.domain, port: port) do |element|
        on_received(element)
      end
    end

    def on_message_received(element)
      instance_exec(element, &on_message_block)
    end

    def on_bound(element)
      @jid = Jid.new(element.elements["/bind/jid/text()"].value)
      establish_session
      require_roster
    end

    def on_replied(element)
      id = element.attribute("id").value
      callback = reply_callbacks.delete(id)
      callback.call(element)
    end

    def on_features_received(element)
      element.each do |feature|
        case
        when feature.name == "bind" && feature.namespace == Namespaces::BIND
          bind
        when feature.name == "starttls" && feature.namespace == Namespaces::TLS
          start_tls
        when feature.name == "mechanisms" && feature.namespace == Namespaces::SASL
          on_mechanisms_received(feature)
        else
          features[feature.name] = feature.namespace
        end
      end
    end

    def on_authentication_succeeded(element)
      connection.open
    end

    def on_authentication_failed(element)
      raise NotImplementedError
    end

    def on_tls_proceeded(element)
      connection.encrypt
    end

    def on_mechanisms_received(element)
      element.each_element("mechanism") do |mechanism|
        mechanisms << mechanism.text
      end
      authenticate if password
    end

    def on_roster_received(element)
      @roster = element.elements.collect("query/item") do |item|
        OpenStruct.new(
          jid: item.attribute("jid").value,
          mention_name: item.attribute("mention_name").value,
          name: item.attribute("name").value,
        )
      end
      attend
      on_connection_established
    end

    def on_connection_established
      join if room_jid
      start_ping_thread
    end

    def features
      @features ||= {}
    end

    def mechanisms
      @mechanisms ||= []
    end

    def reply_callbacks
      @reply_callbacks ||= {}
    end

    def has_reply_callbacks_to?(id)
      reply_callbacks.has_key?(id)
    end

    def post(element, &block)
      if block
        id = generate_id
        element.add_attributes("id" => id)
        reply_callbacks[id] = block
      end
      connection.write(element)
    end

    # See RFC1750 for Randomness Recommendations for Security
    def generate_id
      SecureRandom.hex(8)
    end

    def bind
      post(Elements::Bind.new(resource: jid.resource), &method(:on_bound))
    end

    def establish_session
      post(Elements::Session.new)
    end

    def require_roster
      post(Elements::Roster.new, &method(:on_roster_received))
    end

    def attend
      post(Elements::Presence.new)
    end

    def join
      post(Elements::Join.new(from: jid.strip, to: "#{room_jid}/#{nickname}"))
    end

    def ping
      post(Elements::Ping.new(from: jid.to_s, to: jid.domain))
    end

    def start_tls
      post(Elements::Starttls.new)
    end

    def start
      post(Elements::Stream.new(domain: jid.domain))
    end

    # Only supports PLAIN authentication
    def authenticate
      post(Elements::Auth.new(jid: jid, password: password))
    end

    def start_ping_thread
      Thread.new do
        ping
        sleep(PING_INTERVAL)
      end
    end
  end
end
