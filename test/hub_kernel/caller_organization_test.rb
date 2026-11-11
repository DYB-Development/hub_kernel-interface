require "test_helper"

module HubKernel
  class CallerOrganizationTest < ActiveSupport::TestCase
    module Portal
      extend HubKernel::Exposes

      exposes :reports, takes: %i[period], writes: false, for_clients: true, organization: :organization_id

      def self.reports(organization_id:, period:) = [ organization_id, period ]
    end

    module Holdings
      extend HubKernel::Exposes

      exposes :products, takes: %i[organization_id], writes: false, for_clients: true, organization: :organization_id

      def self.products(organization_id:) = organization_id
    end

    module Ledger
      extend HubKernel::Exposes

      exposes :entries, takes: [], writes: false, for_clients: true, organization: :organization_id

      def self.entries(organization_id:) = raise("entries ran for #{organization_id.inspect}")
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

    test "a client method is never listed with the organization as a value the caller can send" do
      assert_equal [ [] ], Holdings.exposures_for(person: :cleo, account: :acme).map(&:takes)
    end

    test "a client call that sends its own organization value is refused as a value the method does not take" do
      assert_raises(HubKernel::Refused, match: "reports does not take organization_id") { Portal.call_exposed("reports", values: { period: "may", organization_id: "other-org" }, person: :cleo, account: :acme) }
    end

    test "a client caller the host names no organization for is refused before the method runs" do
      HubKernel::Authz.caller_organization = ->(_person, _account) { nil }

      assert_raises(HubKernel::NotAllowed, match: "Ledger entries") { Ledger.call_exposed("entries", values: {}, person: :cleo, account: :acme) }
    end

    test "the exposure check passes a client method that requires the organization value without listing it among the values it takes" do
      assert_empty Portal.exposure_problems
    end
  end
end
