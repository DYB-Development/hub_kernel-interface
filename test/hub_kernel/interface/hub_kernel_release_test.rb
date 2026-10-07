require "test_helper"
require "hub_kernel/interface/hub_kernel_release"

class HubKernelReleaseTest < ActiveSupport::TestCase
  def hub_kernel(version) = Gem::Specification.new { |spec| spec.name = "hub_kernel"; spec.version = version }

  test "a hub_kernel release older than the first one built on hub_kernel-interface is refused" do
    assert_raises(HubKernel::Interface::OlderHubKernelError) { HubKernel::Interface::HubKernelRelease.refuse_older!(hub_kernel("0.18.0")) }
  end

  test "the refusal names the hub_kernel release to upgrade to" do
    error = assert_raises(HubKernel::Interface::OlderHubKernelError) { HubKernel::Interface::HubKernelRelease.refuse_older!(hub_kernel("0.18.0")) }

    assert_equal "hub_kernel 0.18.0 still defines the contract hub_kernel-interface holds, so upgrade hub_kernel to 0.19.0 or later", error.message
  end

  test "no hub_kernel loaded is allowed" do
    assert_nil HubKernel::Interface::HubKernelRelease.refuse_older!(nil)
  end

  test "the first hub_kernel release built on hub_kernel-interface is allowed" do
    assert_nil HubKernel::Interface::HubKernelRelease.refuse_older!(hub_kernel("0.19.0"))
  end
end
