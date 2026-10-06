require "test_helper"
require "hub_kernel/exposes"

module HubKernel
  class ExposesTest < ActiveSupport::TestCase
    module Pantry
      extend HubKernel::Exposes

      exposes :count_jars, takes: %i[shelves], writes: false
    end

    module Supplies
      extend HubKernel::Exposes

      exposes :record_purchase, takes: %i[supplier_id bought_on lines], writes: true
    end

    module Shed
      extend HubKernel::Exposes

      exposes :stack_boxes, takes: %i[rows], writes: true

      def self.stack_boxes(shelves:) = shelves
    end

    module Barn
      extend HubKernel::Exposes

      exposes :add_bale, takes: %i[name weight], writes: true

      def self.add_bale(**fields) = fields
    end

    test "an exposed method is found by its name with the values it takes" do
      assert_equal %i[supplier_id bought_on lines], Supplies.exposed("record_purchase").takes
    end

    test "an exposed name the hub has no method for is named" do
      assert_equal [ "Pantry exposes count_jars, which it has no method for" ], Pantry.exposure_problems
    end

    test "an exposed method listed with values it does not take is named" do
      assert_equal [ "Shed exposes stack_boxes with rows, but it takes shelves" ], Shed.exposure_problems
    end

    test "an exposed method that takes any values is not named for the values it is listed with" do
      assert_empty Barn.exposure_problems
    end

    test "a hub that declares an exposed method is recorded as a hub that exposes methods" do
      assert_includes HubKernel::Interface::ExposingHubs.list, Supplies
    end
  end
end
