require "test_helper"

module HubKernel
  module Interface
    class ServedCheckTest < ActiveSupport::TestCase
      module Bakery
      end

      module Shop
        extend HubKernel::Exposes
      end

      module Pantry
        extend HubKernel::Exposes
      end

      setup { @hubs = HubKernel::Interface.hubs }
      teardown { HubKernel::Interface.hubs = @hubs }

      test "a served entry that exposes no methods is named as exposing no methods to serve" do
        HubKernel::Interface.hubs = [ Bakery ]

        assert_raises(HubKernel::Interface::UnservableHubError, match: "HubKernel::Interface::ServedCheckTest::Bakery exposes no methods to serve") { HubKernel::Interface.check! }
      end

      test "two served entries at the same name are named together with the name they share" do
        HubKernel::Interface.hubs = [ Shop, { "shop" => Pantry } ]

        assert_raises(HubKernel::Interface::UnservableHubError, match: "HubKernel::Interface::ServedCheckTest::Shop and HubKernel::Interface::ServedCheckTest::Pantry both answer at shop") { HubKernel::Interface.check! }
      end
    end
  end
end
