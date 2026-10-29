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

    module Grocer
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false, earlier_answers: { 1 => ->(answer) { answer.except(:currency) } }
    end

    module Baker
      extend HubKernel::Exposes

      exposes :price_of, takes: %i[item], writes: false, earlier_answers: { 1 => ->(answer) { answer[:price] }, 2 => ->(answer) { { price: answer[:cents] } } }
    end

    module Butcher
      extend HubKernel::Exposes

      exposes :weigh_cut, takes: %i[cut], writes: false, answer_shape: { "type" => "integer" }
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

    test "a method exposed without earlier answers reads as having none" do
      assert_empty Supplies.exposed("record_purchase").earlier_answers
    end

    test "an earlier answer is declared for a numbered major as a translation from the answer of the major after it" do
      assert_equal [ [ 1, { cents: 300 } ] ], Grocer.exposed("price_of").earlier_answers.map { |earlier| [ earlier.major, earlier.translate({ cents: 300, currency: "usd" }) ] }
    end

    test "an earlier answer an exposed method declares is read by its major number" do
      assert_equal({ price: 300 }, Baker.exposed("price_of").earlier_answer(2).translate({ cents: 300 }))
    end

    test "a method exposed without an answer shape reads as having none" do
      assert_nil Supplies.exposed("record_purchase").answer_shape
    end

    test "an earlier answer given only a translation reads as having no answer shape" do
      assert_nil Grocer.exposed("price_of").earlier_answer(1).answer_shape
    end

    test "a method is exposed with the JSON Schema of its answer as its answer shape" do
      assert_equal({ "type" => "integer" }, Butcher.exposed("weigh_cut").answer_shape)
    end

    test "a hub that declares an exposed method is recorded as a hub that exposes methods" do
      assert_includes HubKernel::Interface::ExposingHubs.list, Supplies
    end
  end
end
