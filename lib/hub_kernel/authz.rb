module HubKernel
  module Authz
    singleton_class.attr_accessor :check, :caller_kind
  end
end
