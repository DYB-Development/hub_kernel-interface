require "hub_kernel/interface/version"
require "hub_kernel/exposes"

module HubKernel
  module Interface
    class UnservableHubError < StandardError; end

    singleton_class.attr_writer :hubs

    def self.hubs = @hubs ||= []

    def self.find(name) = served[name]

    def self.check!
      problems = unexposed_hubs
      raise UnservableHubError, problems.join("\n") if problems.any?
    end

    def self.unexposed_hubs = served.values.reject { |hub| hub.respond_to?(:exposures) }.map { |hub| "#{hub.name} exposes no methods to serve" }
    private_class_method :unexposed_hubs

    def self.served = hubs.flat_map { |entry| entry.is_a?(Hash) ? entry.to_a : [ [ entry.name.demodulize.underscore, entry ] ] }.to_h
  end
end
