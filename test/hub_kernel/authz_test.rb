require "test_helper"
require "hub_kernel/authz"

module HubKernel
  class AuthzTest < ActiveSupport::TestCase
    setup { @check = HubKernel::Authz.check }
    teardown { HubKernel::Authz.check = @check }

    test "a host sets the permission check that hubs ask" do
      check = ->(*) { true }
      HubKernel::Authz.check = check

      assert_same check, HubKernel::Authz.check
    end
  end
end
