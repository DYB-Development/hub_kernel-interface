require "test_helper"

module HubKernel
  class CallerKindsTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :my_orders, takes: [], writes: false, for_clients: true
      exposes :restock, takes: %i[item], writes: true

      def self.my_orders = "orders"

      def self.restock(item:) = item
    end

    setup do
      @check, @caller_kind, @scope = HubKernel::Authz.check, HubKernel::Authz.caller_kind, HubKernel::Context.scope
      HubKernel::Authz.check = ->(*) { true }
      HubKernel::Context.scope = ->(_account, &call) { call.call }
    end

    teardown { HubKernel::Authz.check, HubKernel::Authz.caller_kind, HubKernel::Context.scope = @check, @caller_kind, @scope }

    test "a method is marked for clients only when its exposes line says so" do
      assert_equal [ [ :my_orders, true ], [ :restock, false ] ], Shop.exposures.map { |exposure| [ exposure.name, exposure.for_clients ] }
    end

    test "a host that does not say how to tell callers apart has every method listed as before" do
      HubKernel::Authz.caller_kind = nil

      assert_equal [ :my_orders, :restock ], Shop.exposures_for(person: :sam, account: :acme).map(&:name)
    end

    test "a method not marked for clients is never listed to a client caller" do
      HubKernel::Authz.caller_kind = ->(_person, _account) { :client }

      assert_equal [ :my_orders ], Shop.exposures_for(person: :cleo, account: :acme).map(&:name)
    end

    test "a method marked for clients is never listed to a staff caller" do
      HubKernel::Authz.caller_kind = ->(_person, _account) { :staff }

      assert_equal [ :restock ], Shop.exposures_for(person: :sam, account: :acme).map(&:name)
    end

    test "a listing asks the host once for the caller's kind, giving it the person and the account" do
      asked = []
      HubKernel::Authz.caller_kind = ->(person, account) { asked << [ person, account ]; :client }

      Shop.exposures_for(person: :cleo, account: :acme)

      assert_equal [ [ :cleo, :acme ] ], asked
    end

    test "a client caller who calls a method not marked for clients is refused as the permission check refuses" do
      HubKernel::Authz.caller_kind = ->(_person, _account) { :client }

      assert_raises(HubKernel::NotAllowed, match: "Shop restock") { Shop.call_exposed("restock", values: { item: "soap" }, person: :cleo, account: :acme) }
    end

    test "asking whether a staff caller may call a method marked for clients answers false" do
      HubKernel::Authz.caller_kind = ->(_person, _account) { :staff }

      assert_equal false, Shop.allows?("my_orders", person: :sam, account: :acme)
    end

    test "the permission check is asked about every method a client caller may reach and no other" do
      asked = []
      HubKernel::Authz.check = ->(_person, action, _account) { asked << action; true }
      HubKernel::Authz.caller_kind = ->(_person, _account) { :client }

      Shop.exposures_for(person: :cleo, account: :acme)

      assert_equal [ "shop:my_orders" ], asked
    end

    test "a caller kind that answers neither client nor staff raises the unknown caller kind error" do
      HubKernel::Authz.caller_kind = ->(_person, _account) { nil }

      assert_raises(HubKernel::UnknownCallerKindError, match: "The caller kind must answer :client or :staff, got nil") { Shop.exposures_for(person: :cleo, account: :acme) }
    end
  end
end
