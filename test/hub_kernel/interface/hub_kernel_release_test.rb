require "test_helper"
require "hub_kernel/interface/hub_kernel_release"

class HubKernelReleaseTest < ActiveSupport::TestCase
  def hub_kernel(version) = Gem::Specification.new { |spec| spec.name = "hub_kernel"; spec.version = version }

  test "a hub_kernel release older than the first one built on hub_kernel-interface is refused" do
    assert_raises(HubKernel::Interface::OlderHubKernelError) { HubKernel::Interface::HubKernelRelease.refuse_older!(hub_kernel("0.18.0")) }
  end
end
