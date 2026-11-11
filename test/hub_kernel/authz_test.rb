require "test_helper"
require "hub_kernel/authz"

module HubKernel
  class AuthzTest < ActiveSupport::TestCase
    setup { @check, @caller_kind = HubKernel::Authz.check, HubKernel::Authz.caller_kind }
    teardown { HubKernel::Authz.check, HubKernel::Authz.caller_kind = @check, @caller_kind }

    test "a host sets the permission check that hubs ask" do
      check = ->(*) { true }
      HubKernel::Authz.check = check

      assert_same check, HubKernel::Authz.check
    end

    test "a host sets how a caller's kind is told from the person and the account" do
      caller_kind = ->(_person, _account) { :client }
      HubKernel::Authz.caller_kind = caller_kind

      assert_same caller_kind, HubKernel::Authz.caller_kind
    end
  end
end
