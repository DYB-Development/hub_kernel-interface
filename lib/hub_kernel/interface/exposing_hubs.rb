module HubKernel
  module Interface
    module ExposingHubs
      def self.add(hub)
        list.reject! { |listed| listed.name == hub.name }
        list << hub
      end

      def self.list = @list ||= []
    end
  end
end
