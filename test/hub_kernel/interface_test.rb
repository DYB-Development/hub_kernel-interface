require "test_helper"
require "open3"

module HubKernel
  class InterfaceTest < ActiveSupport::TestCase
    test "requiring the gem alone is enough to expose a method" do
      script = 'require "hub_kernel-interface"; module Supplies; extend HubKernel::Exposes; exposes :record_purchase, takes: [], writes: true; end; print "exposed"'
      output, = Open3.capture2e(RbConfig.ruby, "-I", File.expand_path("../../lib", __dir__), "-e", script)

      assert_equal "exposed", output
    end

    test "requiring the gem alone is enough to give call reasons" do
      script = 'require "hub_kernel-interface"; print HubKernel::Interface::CallReasons.missing_record(Struct.new(:model, :id).new("Shop", 1))'
      output, = Open3.capture2e(RbConfig.ruby, "-I", File.expand_path("../../lib", __dir__), "-e", script)

      assert_equal "No shop has the id 1", output
    end
  end
end
