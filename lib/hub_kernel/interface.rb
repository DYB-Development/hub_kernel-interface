require "hub_kernel/interface/version"
require "hub_kernel/exposes"

module HubKernel
  module Interface
    singleton_class.attr_writer :hubs

    def self.hubs = @hubs ||= []

    def self.find(name) = served[name]

    def self.served = hubs.flat_map { |entry| entry.is_a?(Hash) ? entry.to_a : [ [ entry.name.demodulize.underscore, entry ] ] }.to_h
  end
end
