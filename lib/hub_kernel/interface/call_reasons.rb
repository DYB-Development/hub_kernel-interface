require "hub_kernel/exposes"

module HubKernel
  module Interface
    module CallReasons
      def self.refuse_unlisted_values(hub, name, values:, person:, account:)
        raise HubKernel::NotAllowed, "#{hub.name.demodulize} #{name}" unless hub.exposures_for(person: person, account: account).any? { |exposure| exposure.name.to_s == name.to_s }

        unlisted = values.keys - hub.exposed(name).takes
        raise HubKernel::Refused, "#{name} does not take #{unlisted.join(", ")}" if unlisted.any?
      end

      def self.missing_record(missing) = "No #{missing.model.demodulize.underscore.humanize(capitalize: false)} has the id #{missing.id}"
    end
  end
end
