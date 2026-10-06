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
    end
  end
end
