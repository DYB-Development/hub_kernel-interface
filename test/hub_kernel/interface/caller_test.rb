require "test_helper"

module HubKernel
  module Interface
    class CallerTest < ActiveSupport::TestCase
      setup { @person_method, @account_method = HubKernel::Interface.person_method, HubKernel::Interface.account_method }
      teardown { HubKernel::Interface.person_method, HubKernel::Interface.account_method = @person_method, @account_method }

      test "a host sets one person method and one account method that every interface gem reads" do
        HubKernel::Interface.person_method = :hub_person
        HubKernel::Interface.account_method = :hub_account

        assert_equal [ :hub_person, :hub_account ], [ HubKernel::Interface.person_method, HubKernel::Interface.account_method ]
      end
    end
  end
end
