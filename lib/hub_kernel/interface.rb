require "hub_kernel/interface/version"
require "hub_kernel/exposes"

module HubKernel
  module Interface
    singleton_class.attr_writer :hubs

    def self.hubs = @hubs ||= []

    def self.find(name) = hubs.to_h { |hub| [ hub.name.demodulize.underscore, hub ] }[name]
  end
end
