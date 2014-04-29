require "spec_helper"

describe Xrc::Client do
  let(:client) do
    described_class.new(options)
  end

  let(:options) do
    { jid: jid }
  end

  let(:jid) do
    "#{node}@#{domain}/#{resource}"
  end

  let(:node) do
    "alice"
  end

  let(:domain) do
    "example.com"
  end

  let(:resource) do
    "bot"
  end

  describe "#initialize" do
    it "takes :jid string option as an account's JID" do
      client.should be_true
      client.jid.node.should == node
      client.jid.domain.should == domain
      client.jid.resource.should == resource
    end
  end
end
