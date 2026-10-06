require "test_helper"

module HubKernel
  module Interface
    class ServedHubsTest < ActiveSupport::TestCase
      module Supplies
        extend HubKernel::Exposes
      end

      module FieldNotes
        extend HubKernel::Exposes
      end

      setup { @hubs = HubKernel::Interface.hubs }
      teardown { HubKernel::Interface.hubs = @hubs }

      test "a host names its served hubs once and an interface gem reads that list" do
        HubKernel::Interface.hubs = [ Supplies ]

        assert_equal [ Supplies ], HubKernel::Interface.hubs
      end

      test "a hub listed alone is served at its module name in snake case" do
        HubKernel::Interface.hubs = [ FieldNotes ]

        assert_equal FieldNotes, HubKernel::Interface.find("field_notes")
      end

      test "a hub listed as a one-pair name and hub is served at the name given" do
        HubKernel::Interface.hubs = [ { "notes" => FieldNotes } ]

        assert_equal FieldNotes, HubKernel::Interface.find("notes")
      end

      test "a hub listed under a chosen name is not served at its module name" do
        HubKernel::Interface.hubs = [ { "notes" => FieldNotes } ]

        assert_nil HubKernel::Interface.find("field_notes")
      end
    end
  end
end
