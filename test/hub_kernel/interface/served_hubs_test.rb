require "test_helper"

module HubKernel
  module Interface
    class ServedHubsTest < ActiveSupport::TestCase
      module Supplies
        extend HubKernel::Exposes
      end

      setup { @hubs = HubKernel::Interface.hubs }
      teardown { HubKernel::Interface.hubs = @hubs }

      test "a host names its served hubs once and an interface gem reads that list" do
        HubKernel::Interface.hubs = [ Supplies ]

        assert_equal [ Supplies ], HubKernel::Interface.hubs
      end
    end
  end
end
