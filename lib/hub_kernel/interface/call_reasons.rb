require "hub_kernel/exposes"

module HubKernel
  module Interface
    module CallReasons
      def self.refuse_unlisted_values(hub, name, values:, person:, account:)
        unlisted = values.keys - hub.exposed(name).takes
        return if unlisted.none?

        raise HubKernel::NotAllowed, "#{hub.name.demodulize} #{name}" unless hub.allows?(name, person: person, account: account)
        raise HubKernel::Refused, "#{name} does not take #{unlisted.join(", ")}" if unlisted.any?
      end

      def self.missing_record(missing) = "No #{missing.model.demodulize.underscore.humanize(capitalize: false)} has the id #{missing.id}"
    end
  end
end
