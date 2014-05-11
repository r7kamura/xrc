# Xrc
XMPP Ruby Client.

## Usage
```ruby
# Loads all classes & modules defined in this library.
require "xrc"

# Constructs a new Client class to connect to a XMPP server.
client = Xrc::Client.new(
  jid: "foo@example.com",      # required
  nickname: "bot"              # optional
  password: "xxx",             # optional
  port: 5222,                  # optional, default: 5222
  room_jid: "bar@example.com", # optional
)

# Registers a callback called when client received a new private message.
client.on_private_message do |message|
  if message.body == "ping"
    reply(body: "pong", to: message)
  end
end

# Registers a callback called when client received a new room message.
client.on_room_message do |message|
  puts "Received room message: #{message.body}"
end

# Registers a callback called when client received a new subject message.
client.on_subject do |message|
  puts "Received subject: #{message.subject}"
end

# Connects to a XMPP server and waits for new messages.
client.connect
```
