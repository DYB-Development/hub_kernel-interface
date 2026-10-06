require "test_helper"

module HubKernel
  class CallExposedTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false

      def self.price_of(item:) = "#{item} costs 3"
    end

    module Labels
      extend HubKernel::Exposes

      exposes :label, takes: %i[item], writes: false

      def self.label(**values) = values
    end

    setup do
      @check, @scope = HubKernel::Authz.check, HubKernel::Context.scope
      HubKernel::Authz.check = ->(*) { true }
      HubKernel::Context.scope = ->(_account, &call) { call.call }
    end

    teardown { HubKernel::Authz.check, HubKernel::Context.scope = @check, @scope }

    test "calling an exposed method by name runs it and returns its answer" do
      assert_equal "soap costs 3", Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme)
    end

    test "a value the method is not listed with is left out of the call" do
      assert_equal({ item: "soap" }, Labels.call_exposed("label", values: { item: "soap", colour: "red" }, person: :sam, account: :acme))
    end

    test "calling a name the hub does not expose raises an error naming the hub and the name" do
      assert_raises(HubKernel::UnexposedMethodError, match: "Shop does not expose close_shop") { Shop.call_exposed("close_shop", values: {}, person: :sam, account: :acme) }
    end

    test "a call the permission check refuses raises the not-allowed error naming the hub and the method" do
      HubKernel::Authz.check = ->(*) { false }

      assert_raises(HubKernel::NotAllowed, match: "Shop price_of") { Shop.call_exposed("price_of", values: { item: "soap" }, person: :sam, account: :acme) }
    end
  end
end
