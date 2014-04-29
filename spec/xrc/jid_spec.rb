require "spec_helper"

describe Xrc::Jid do
  let(:instance) do
    described_class.new(*args)
  end

  let(:args) do
    [jid]
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
    it "parses node, domain, resource sections" do
      instance.node.should == node
      instance.domain.should == domain
      instance.resource.should == resource
    end
  end
end
