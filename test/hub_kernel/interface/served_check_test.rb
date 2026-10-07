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

      module Cellar
        extend HubKernel::Exposes

        exposes :count_bottles, takes: [], writes: false
      end

      module Larder
        extend HubKernel::Exposes

        exposes :count_jars, takes: [], writes: false

        def self.count_jars = 4
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

      test "a served hub whose exposed list has a problem has that problem named" do
        HubKernel::Interface.hubs = [ Cellar ]

        assert_raises(HubKernel::Interface::UnservableHubError, match: "Cellar exposes count_bottles, which it has no method for") { HubKernel::Interface.check! }
      end

      test "every problem in a list is named in one error raised by the check" do
        HubKernel::Interface.hubs = [ Bakery, Cellar ]

        error = assert_raises(HubKernel::Interface::UnservableHubError) { HubKernel::Interface.check! }
        assert_equal [ "HubKernel::Interface::ServedCheckTest::Bakery exposes no methods to serve", "Cellar exposes count_bottles, which it has no method for" ], error.message.lines(chomp: true)
      end

      test "a correct served list passes the check" do
        HubKernel::Interface.hubs = [ Larder, { "jars" => Larder } ]

        assert_nothing_raised { HubKernel::Interface.check! }
      end

      test "a served hub that uses the contract but declares no exposed methods is named" do
        HubKernel::Interface.hubs = [ Pantry ]

        assert_raises(HubKernel::Interface::UnservableHubError, match: "HubKernel::Interface::ServedCheckTest::Pantry exposes no methods to serve") { HubKernel::Interface.check! }
      end
    end
  end
end
