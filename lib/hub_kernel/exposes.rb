require "active_support/core_ext/string/inflections"
require "hub_kernel/authz"

module HubKernel
  class MissingArgumentError < ArgumentError; end
  class UnwiredPortError < StandardError; end

  module Exposes
    Exposed = Data.define(:name, :takes, :writes)

    def exposes(name, takes:, writes:)
      exposed_methods[name.to_s] = Exposed.new(name: name, takes: takes, writes: writes)
    end

    def exposed(name) = exposed_methods[name.to_s]

    def exposures = exposed_methods.values

    def exposures_for(person:, account:)
      refuse_without_caller(person, account)

      exposures.select { |exposure| allowed?(exposure, person, account) }
    end

    def exposure_problems
      exposed_methods.values.filter_map { |exposure| exposure_problem(exposure) }
    end

    private

    def exposed_methods = @exposed_methods ||= {}

    def exposing_hub = name.demodulize

    def refuse_without_caller(person, account)
      raise MissingArgumentError, "A call by name needs a person" if person.nil?
      raise MissingArgumentError, "A call by name needs an account" if account.nil?
    end

    def allowed?(exposure, person, account)
      raise UnwiredPortError, "hub_kernel's permission check is not filled" unless Authz.check

      Authz.check.call(person, "#{exposing_hub.underscore}:#{exposure.name}", account)
    end

    def exposure_problem(exposure)
      return "#{exposing_hub} exposes #{exposure.name}, which it has no method for" unless respond_to?(exposure.name)
      return if takes_listed_values?(exposure)

      "#{exposing_hub} exposes #{exposure.name} with #{exposure.takes.join(", ")}, but it takes #{keywords(exposure, :keyreq, :key).join(", ")}"
    end

    def takes_listed_values?(exposure)
      (keywords(exposure, :keyreq) - exposure.takes).empty? && (takes_any_values?(exposure) || (exposure.takes - keywords(exposure, :keyreq, :key)).empty?)
    end

    def takes_any_values?(exposure) = method(exposure.name).parameters.any? { |kind, _| kind == :keyrest }

    def keywords(exposure, *kinds) = method(exposure.name).parameters.filter_map { |kind, value| value if kinds.include?(kind) }
  end
end
