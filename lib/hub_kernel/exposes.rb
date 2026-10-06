require "active_support/core_ext/string/inflections"

module HubKernel
  module Exposes
    Exposed = Data.define(:name, :takes, :writes)

    def exposes(name, takes:, writes:)
      exposed_methods[name.to_s] = Exposed.new(name: name, takes: takes, writes: writes)
    end

    def exposed(name) = exposed_methods[name.to_s]

    def exposure_problems
      exposed_methods.values.filter_map { |exposure| exposure_problem(exposure) }
    end

    private

    def exposed_methods = @exposed_methods ||= {}

    def exposing_hub = name.demodulize

    def exposure_problem(exposure)
      "#{exposing_hub} exposes #{exposure.name}, which it has no method for" unless respond_to?(exposure.name)
    end
  end
end
