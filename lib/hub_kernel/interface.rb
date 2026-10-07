require "hub_kernel/interface/version"
require "hub_kernel/exposes"
require "hub_kernel/interface/call_reasons"

module HubKernel
  module Interface
    class UnservableHubError < StandardError; end

    singleton_class.attr_writer :hubs

    def self.hubs = @hubs ||= []

    def self.find(name) = served[name]

    def self.check!
      problems = unexposed_hubs + shared_names + exposure_problems
      raise UnservableHubError, problems.join("\n") if problems.any?
    end

    def self.unexposed_hubs = served.values.reject { |hub| hub.respond_to?(:exposures) && hub.exposures.any? }.map { |hub| "#{hub.name} exposes no methods to serve" }

    def self.shared_names
      served_pairs.group_by(&:first).select { |_name, pairs| pairs.size > 1 }.map do |name, pairs|
        "#{pairs.map { |_name, hub| hub.name }.join(" and ")} both answer at #{name}"
      end
    end

    def self.exposure_problems = served.values.select { |hub| hub.respond_to?(:exposure_problems) }.flat_map(&:exposure_problems)

    def self.served_pairs = hubs.flat_map { |entry| entry.is_a?(Hash) ? entry.to_a : [ [ entry.name.demodulize.underscore, entry ] ] }
    private_class_method :unexposed_hubs, :shared_names, :exposure_problems, :served_pairs

    def self.served = served_pairs.to_h
  end
end
