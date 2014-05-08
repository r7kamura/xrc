# Xrc
XMPP Ruby Client.

## Usage
```ruby
require "xrc"

client = Xrc::Client.new(
  jid: YOUR_JID, # e.g. "foo@example.com"
  password: YOUR_PASSWORD, # optional
)
client.run
```
