require "test_helper"

class GemFilesTest < ActiveSupport::TestCase
  test "the packaged gem ships its info, install and develop agents" do
    files = Gem::Specification.load(File.expand_path("../hub_kernel-interface.gemspec", __dir__)).files

    assert_equal %w[the_local/agents/hub_kernel-interface-develop.md the_local/agents/hub_kernel-interface-info.md the_local/agents/hub_kernel-interface-install.md], files.grep(%r{\Athe_local/agents/}).sort
  end
end
