require "spec_helper"

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

  describe "#connect" do
    it "connects to XMPP server via TCP socket" do
      instance.connect.should be_a TCPSocket
    end
  end
end
