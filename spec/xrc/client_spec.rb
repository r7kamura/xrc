require "spec_helper"
require "active_support/core_ext/string/strip"
require "stringio"

describe Xrc::Client do
  after do
    server.close
  end

  let!(:server) do
    TCPServer.new(port)
  end

  let(:instance) do
    described_class.new(*args)
  end

  let(:args) do
    [options]
  end

  let(:options) do
    {
      jid: jid,
      port: port,
    }
  end

  let(:port) do
    5222
  end

  let(:jid) do
    "#{node}@#{domain}/#{resource}"
  end

  let(:node) do
    "alice"
  end

  let(:domain) do
    "localhost"
  end

  let(:resource) do
    "bot"
  end

  let(:socket) do
    StringIO.new <<-EOS.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <stream:stream
        from='#{domain}'
        id='5d29a171a9472e73'
        xmlns:stream='http://etherx.jabber.org/streams'
        version='1.0'
        xmlns='jabber:client'>
        <stream:features>
          <starttls xmlns='#{Namespaces::TLS}'/>
          <required/>
        </stream:features>
    EOS
  end

  describe "#run" do
    before do
      pending
      instance.stub(socket: socket)
    end

    it "parses received XML message" do
      instance.run
    end
  end
end
