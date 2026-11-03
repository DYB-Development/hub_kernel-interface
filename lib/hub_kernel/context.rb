module HubKernel
  module Context
    singleton_class.attr_accessor :scope

    def self.person = Thread.current[:hub_kernel_person]

    def self.with_person(person)
      previous = self.person
      Thread.current[:hub_kernel_person] = person
      yield
    ensure
      Thread.current[:hub_kernel_person] = previous
    end
  end
end
