require "test_helper"
require "open3"

class OlderHubKernelLoadTest < ActiveSupport::TestCase
  test "requiring hub_kernel-interface beside an older hub_kernel stops with the release to upgrade to" do
    script = 'Gem.loaded_specs["hub_kernel"] = Gem::Specification.new { |spec| spec.name = "hub_kernel"; spec.version = "0.18.0" }; require "hub_kernel-interface"'

    output, _status = Open3.capture2e("bundle", "exec", "ruby", "-Ilib", "-e", script, chdir: File.expand_path("../../..", __dir__))

    assert_includes output, "upgrade hub_kernel to 0.19.0 or later (HubKernel::Interface::OlderHubKernelError)"
  end
end
