require "test_helper"

module HubKernel
  class ExposuresTest < ActiveSupport::TestCase
    module Shop
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false
      exposes :restock, takes: %i[item], writes: true

      def self.price_of(item:) = item

      def self.restock(item:) = item
    end

    setup { @check = HubKernel::Authz.check }
    teardown { HubKernel::Authz.check = @check }

    test "a hub gives every exposed entry with its name, the values it takes and whether it writes" do
      assert_equal [ [ :price_of, %i[item], false ], [ :restock, %i[item], true ] ], Shop.exposures.map { |exposure| [ exposure.name, exposure.takes, exposure.writes ] }
    end

    test "a hub gives only the entries the host's permission check allows a person on an account" do
      HubKernel::Authz.check = ->(person, action, account) { person == :sam && account == :acme && action == "shop:price_of" }

      assert_equal [ :price_of ], Shop.exposures_for(person: :sam, account: :acme).map(&:name)
    end

    test "asking what a person may call with no person is refused" do
      assert_raises(HubKernel::MissingArgumentError, match: "needs a person") { Shop.exposures_for(person: nil, account: :acme) }
    end

    test "asking what a person may call with no account is refused" do
      assert_raises(HubKernel::MissingArgumentError, match: "needs an account") { Shop.exposures_for(person: :sam, account: nil) }
    end

    test "asking what a person may call while the permission check is unset raises the unwired error" do
      HubKernel::Authz.check = nil

      assert_raises(HubKernel::UnwiredPortError, match: "hub_kernel's permission check is not filled") { Shop.exposures_for(person: :sam, account: :acme) }
    end

    test "a permission check that answers neither true nor false raises the non-boolean answer error" do
      HubKernel::Authz.check = ->(*) { "yes" }

      assert_raises(HubKernel::NonBooleanAnswerError, match: 'The permission check must answer true or false, got "yes"') { Shop.exposures_for(person: :sam, account: :acme) }
    end
  end
end
