require "test_helper"

module HubKernel
  module Interface
    class ServedCheckTest < ActiveSupport::TestCase
      module Bakery
      end

      setup { @hubs = HubKernel::Interface.hubs }
      teardown { HubKernel::Interface.hubs = @hubs }

      test "a served entry that exposes no methods is named as exposing no methods to serve" do
        HubKernel::Interface.hubs = [ Bakery ]

        assert_raises(HubKernel::Interface::UnservableHubError, match: "HubKernel::Interface::ServedCheckTest::Bakery exposes no methods to serve") { HubKernel::Interface.check! }
      end
    end
  end
end
