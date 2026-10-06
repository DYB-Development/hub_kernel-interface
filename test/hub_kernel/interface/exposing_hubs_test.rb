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

      test "a hub recorded again under the same name, as after a code reload, is listed once" do
        reloaded = Module.new
        def reloaded.name = Kitchen.name

        ExposingHubs.add(Kitchen)
        ExposingHubs.add(reloaded)

        assert_equal [ reloaded ], ExposingHubs.list.select { |hub| hub.name == Kitchen.name }
      end
    end
  end
end
