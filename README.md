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

# Registers a callback called when client received a message with body.
client.on_message do |message|
  puts "Received message: #{message.body}"
end

# Registers a callback called when client received a message with subject.
client.on_subject do |message|
  puts "Received subject: #{message.subject}"
end

# Registers a callback called when client received a new XML element from server.
client.on_event do |element|
  puts "Received XML element: #{element}"
end

# Connects to a XMPP server and waits for new messages.
client.connect
```
