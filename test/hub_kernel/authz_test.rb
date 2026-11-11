require "test_helper"
require "hub_kernel/authz"

module HubKernel
  class AuthzTest < ActiveSupport::TestCase
    setup { @check, @caller_kind, @caller_organization = HubKernel::Authz.check, HubKernel::Authz.caller_kind, HubKernel::Authz.caller_organization }
    teardown { HubKernel::Authz.check, HubKernel::Authz.caller_kind, HubKernel::Authz.caller_organization = @check, @caller_kind, @caller_organization }

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

    test "a host sets how a caller's organization is named from the person and the account" do
      caller_organization = ->(_person, _account) { "acme-org" }
      HubKernel::Authz.caller_organization = caller_organization

      assert_same caller_organization, HubKernel::Authz.caller_organization
    end
  end
end
