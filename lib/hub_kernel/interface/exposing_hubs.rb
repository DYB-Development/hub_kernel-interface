module HubKernel
  module Interface
    module ExposingHubs
      def self.add(hub)
        list << hub
      end

      def self.list = @list ||= []
    end
  end
end
