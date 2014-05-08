module Xrc
  class HostsResolver
    def self.call(*args)
      new(*args).call
    end

    attr_reader :domain

    def initialize(domain)
      @domain = domain
    end

    def call
      resolved_hosts + [domain]
    end

    private

    def resolved_hosts
      sorted_srvs.lazy.map(&:target).map(&:to_s).to_a
    end

    def sorted_srvs
      @sorted_srvs ||= srvs.sort_by do |resource|
        [resource.priority, -resource.weight]
      end
    end

    def srvs
      Resolv::DNS.open do |dns|
        dns.getresources(name, type_class)
      end
    end

    def name
      "_xmpp-client._tcp.#{domain}"
    end

    def type_class
      Resolv::DNS::Resource::IN::SRV
    end
  end
end
