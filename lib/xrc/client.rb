module Xrc
  class Client
    DEFAULT_PORT = 5222

    PING_INTERVAL = 60

    attr_accessor :users

    attr_reader :connection, :options

    def initialize(options = {})
      @options = options
    end

    def run
      connect
    end

    def on_received(element)
      case
      when element.attribute("id") && has_reply_callbacks_to?(element.attribute("id").value)
        on_replied(element)
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

    log :on_received do |element|
      "Received:\n" + "#{REXML::Formatters::Pretty.new(2).write(element, '')}".indent(2)
    end

    private

    def jid
      @jid ||= Jid.new(options[:jid])
    end

    def password
      options[:password]
    end

    def nickname
      options[:nickname]
    end

    def port
      options[:port] || DEFAULT_PORT
    end

    def room_jid
      Jid.new("#{options[:room_jid]}") if options[:room_jid]
    end

    def connection
      @connection ||= Connection.new(domain: domain, port: port) do |element|
        on_received(element)
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
      self.users = element.elements.collect("query/item") do |item|
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

    def connect
      connection.connect
    end

    log :connect do
      "Connecting to #{domain}:#{port}"
    end

    def socket
      connection.socket
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

    def domain
      jid.domain
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
      post(Elements::Stream.new(domain: domain))
    end

    def authenticate
      case
      when mechanisms.include?("PLAIN")
        auth = Elements::Auth.new(jid: jid, password: password)
        post(auth)
      else
        raise NotImplementedError
      end
    end

    def start_ping_thread
      Thread.new do
        ping
        sleep(PING_INTERVAL)
      end
    end
  end
end
