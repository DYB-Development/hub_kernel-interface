require "hub_kernel/interface/version"
require "hub_kernel/exposes"

module HubKernel
  module Interface
    singleton_class.attr_writer :hubs

    def self.hubs = @hubs ||= []
  end
end
