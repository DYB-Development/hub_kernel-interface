require "test_helper"
require "hub_kernel/interface/call_reasons"

module HubKernel
  module Interface
    class CallReasonsTest < ActiveSupport::TestCase
      module Shop
        extend HubKernel::Exposes

        exposes :price_of, takes: %i[item], writes: false

        def self.price_of(item:) = item
      end

      setup do
        @check = HubKernel::Authz.check
        HubKernel::Authz.check = ->(person, _action, _account) { person == :sam }
      end

      teardown { HubKernel::Authz.check = @check }

      test "a permitted call that sends values the method is not listed with is refused naming the method and every such value" do
        assert_raises(HubKernel::Refused, match: "price_of does not take colour, size") do
          CallReasons.refuse_unlisted_values(Shop, "price_of", values: { item: "soap", colour: "red", size: 2 }, person: :sam, account: :acme)
        end
      end

      test "a call the permission check refuses is refused as not allowed whatever values it sends" do
        assert_raises(HubKernel::NotAllowed) do
          CallReasons.refuse_unlisted_values(Shop, "price_of", values: { item: "soap", colour: "red" }, person: :lee, account: :acme)
        end
      end

      test "a call that sends only listed values goes on to the method" do
        assert_nothing_raised do
          CallReasons.refuse_unlisted_values(Shop, "price_of", values: { item: "soap" }, person: :sam, account: :acme)
        end
      end
    end
  end
end
