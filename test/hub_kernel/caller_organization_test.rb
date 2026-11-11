require "test_helper"

module HubKernel
  class CallerOrganizationTest < ActiveSupport::TestCase
    module Portal
      extend HubKernel::Exposes

      exposes :reports, takes: %i[period], writes: false, for_clients: true, organization: :organization_id

      def self.reports(organization_id:, period:) = [ organization_id, period ]
    end

    setup do
      @check, @caller_kind, @caller_organization, @scope = HubKernel::Authz.check, HubKernel::Authz.caller_kind, HubKernel::Authz.caller_organization, HubKernel::Context.scope
      HubKernel::Authz.check = ->(*) { true }
      HubKernel::Authz.caller_kind = ->(_person, _account) { :client }
      HubKernel::Authz.caller_organization = ->(_person, _account) { "acme-org" }
      HubKernel::Context.scope = ->(_account, &call) { call.call }
    end

    teardown { HubKernel::Authz.check, HubKernel::Authz.caller_kind, HubKernel::Authz.caller_organization, HubKernel::Context.scope = @check, @caller_kind, @caller_organization, @scope }

    test "a client method receives the organization the host names for the caller" do
      assert_equal [ "acme-org", "may" ], Portal.call_exposed("reports", values: { period: "may" }, person: :cleo, account: :acme)
    end
  end
end
