module HubKernel
  module Interface
    class OlderHubKernelError < StandardError; end

    module HubKernelRelease
      FIRST_BUILT_ON_INTERFACE = Gem::Version.new("0.19.0")

      def self.refuse_older!(spec)
        return if spec.nil? || spec.version >= FIRST_BUILT_ON_INTERFACE

        raise OlderHubKernelError, "hub_kernel #{spec.version} still defines the contract hub_kernel-interface holds, so upgrade hub_kernel to #{FIRST_BUILT_ON_INTERFACE} or later"
      end
    end
  end
end
