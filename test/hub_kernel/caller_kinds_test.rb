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

    test "a method is marked for clients only when its exposes line says so" do
      assert_equal [ [ :my_orders, true ], [ :restock, false ] ], Shop.exposures.map { |exposure| [ exposure.name, exposure.for_clients ] }
    end
  end
end
