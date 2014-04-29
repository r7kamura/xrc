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
      <!-- Edited by XMLSpy -->
      <note>
        <to>Tove</to>
        <from>Jani</from>
        <heading>Reminder</heading>
        <body>Don't forget me this weekend!</body>
      </note>
    EOS
  end

  describe "#connect" do
    it "connects to XMPP server via TCP socket" do
      instance.connect.should be_a TCPSocket
    end
  end

  describe "#run" do
    before do
      instance.stub(socket: socket)
    end

    it "parses received XML message" do
      instance.parser.should_receive(:end_document)
      instance.run
    end
  end
end
