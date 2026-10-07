require_relative "lib/hub_kernel/interface/version"

Gem::Specification.new do |spec|
  spec.name        = "hub_kernel-interface"
  spec.version     = HubKernel::Interface::VERSION
  spec.authors     = [ "tylercschneider" ]
  spec.email       = [ "tylercschneider@gmail.com" ]
  spec.homepage    = "https://github.com/DYB-Development/hub_kernel-interface"
  spec.summary     = "The exposed-method contract every hub_kernel interface gem builds on."
  spec.description = "hub_kernel-interface holds what a hub exposes, who may call it, and calling it in an account's scope, so an interface gem can serve hubs without depending on the rest of hub_kernel."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{lib,the_local}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "activesupport", ">= 8.1.3"
end
