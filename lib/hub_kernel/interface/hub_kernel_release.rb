module HubKernel
  module Interface
    class OlderHubKernelError < StandardError; end

    module HubKernelRelease
      FIRST_BUILT_ON_INTERFACE = Gem::Version.new("0.19.0")

      def self.refuse_older!(spec)
        raise OlderHubKernelError if spec.version < FIRST_BUILT_ON_INTERFACE
      end
    end
  end
end
