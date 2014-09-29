module Xrc
  class Client
    DEFAULT_PORT = 5222

    PING_INTERVAL = 30

    # @return [Xrc::Roster] Users information existing in the server
    attr_reader :users

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

    # Registers a callback called when a client connected to server
    # @yield Executes a given callback in the Client's context
    # @return [Proc] Returns given block
    # @example
    #   client.on_connection_established do
    #     puts "connection established!"
    #   end
    #
    def on_connection_established(&block)
      @on_connection_established_block = block
    end

    # Registers a callback called when client received a new private message (a.k.a. 1vs1 message)
    # @yield Executes a given callback in the Client's context
    # @yieldparam element [Xrc::Message] Represents a given message
    # @return [Proc] Returns given block
    # @example
    #   client.on_private_message do |message|
    #     puts "#{message.from}: #{message.body}"
    #   end
    #
    def on_private_message(&block)
      @on_private_message_block = block
    end

    # Registers a callback called when client received a new room message
    # @yield Executes a given callback in the Client's context
    # @yieldparam element [Xrc::Message] Represents a given message
    # @return [Proc] Returns given block
    # @example
    #   client.on_room_message do |message|
    #     puts "#{message.from}: #{message.body}"
    #   end
    #
    def on_room_message(&block)
      @on_room_message_block = block
    end

    # Registers a callback called when client received a new message with subject
    # @yield Executes a given callback in the Client's context
    # @yieldparam element [Xrc::Message] Represents a given message
    # @return [Proc] Returns given block
    # @example
    #   client.on_subject do |element|
    #     puts "Subject: #{element.subject}"
    #   end
    #
    def on_subject(&block)
      @on_subject_block = block
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

    # Registers a callback for invitation message
    # @return [Proc] Returns given block
    def on_invite(&block)
      @on_invite_block = block
    end

    # Replies to given message
    # @option options [Xrc::Messages::Base] :to A message object given from server
    # @option options [String] :body A text to be sent to server
    # @return [REXML::Element] Returns an element sent to server
    # @example
    #   client.reply(body: "Thanks", to: message)
    def reply(options)
      say(
        body: options[:body],
        from: options[:to].to,
        to: options[:to].from,
        type: options[:to].type,
      )
    end

    # Send a message
    # @option options [String] :body Message body
    # @option options [String] :from Sender's JID
    # @option options [String] :to Address JID
    # @option options [String] :type Message type (e.g. chat, groupchat)
    # @return [REXML::Element] Returns an element sent to server
    # @example
    #   client.say(body: "Thanks", from: "alice@example.com", to: "bob@example.com", type: "chat")
    def say(options)
      post Elements::Message.new(
        body: options[:body],
        from: options[:from],
        to: options[:to],
        type: options[:type],
      )
    end

    # @return [String] Mention name of this account
    # @example
    #   client.mention_name #=> "alice"
    def mention_name
      users[jid].try(:mention_name)
    end

    def join(jids)
      Array(jids).each do |room_jid|
        post(Elements::Join.new(from: jid.strip, to: "#{room_jid}/#{nickname}"))
      end
    end

    private
    def on_connection_established_block
      @on_connection_established_block ||= ->() {}
    end

    def on_event_block
      @on_event_block ||= ->(element) {}
    end

    def on_private_message_block
      @on_private_message_block ||= ->(element) {}
    end

    def on_room_message_block
      @on_room_message_block ||= ->(element) {}
    end

    def on_subject_block
      @on_subject_block ||= ->(element) {}
    end

    def on_invite_block
      @on_invite_block ||= ->(element) {}
    end

    def on_received(element)
      on_event_block.call(element)
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

    def hosts
      @options[:hosts]
    end

    def port
      @options[:port] || DEFAULT_PORT
    end

    # @return [Array<Xrc::Jid>] An array of Room JIDs a client will log in
    def room_jids
      @room_jids ||= raw_room_jids.map {|raw| Jid.new(raw) }
    end

    def raw_room_jids
      @options[:room_jid].try(:split, ",") || []
    end

    def connection
      @connection ||= Connection.new(domain: jid.domain, hosts: hosts, port: port) do |element|
        on_received(element)
      end
    end

    def on_message_received(element)
      case message = MessageBuilder.build(element)
      when Messages::RoomMessage
        on_room_message_block.call(message)
      when Messages::PrivateMessage
        on_private_message_block.call(message)
      when Messages::Subject
        on_subject_block.call(message)
      when Messages::Invite
        on_invite_block.call(message)
      end
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
          break
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
      @users = Roster.new(element)
      attend
      join(room_jids)
      start_ping_thread
      on_connection_established_block.call()
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
      element
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
        loop do
          ping
          sleep(PING_INTERVAL)
        end
      end
    end
  end
end
