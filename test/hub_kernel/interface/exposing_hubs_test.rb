require "test_helper"
require "hub_kernel/interface/exposing_hubs"

module HubKernel
  module Interface
    class ExposingHubsTest < ActiveSupport::TestCase
      module Kitchen; end

      setup { @list = ExposingHubs.list.dup }
      teardown { ExposingHubs.list.replace(@list) }

      test "a recorded hub is on the list of hubs that expose methods" do
        ExposingHubs.add(Kitchen)

        assert_includes ExposingHubs.list, Kitchen
      end
    end
  end
end
