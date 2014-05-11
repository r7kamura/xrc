# Xrc
XMPP Ruby Client.

## Usage
```ruby
require "xrc"

client = Xrc::Client.new(
  jid: "foo@example.com", # required
  password: "xxx",        # optional
)
client.connect
```
