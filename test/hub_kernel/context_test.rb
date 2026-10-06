require "test_helper"
require "hub_kernel/context"

module HubKernel
  class ContextTest < ActiveSupport::TestCase
    setup { @scope = HubKernel::Context.scope }
    teardown { HubKernel::Context.scope = @scope }

    test "a host sets the account scope that hubs run calls inside" do
      scope = ->(_account, &call) { call.call }
      HubKernel::Context.scope = scope

      assert_same scope, HubKernel::Context.scope
    end
  end
end
