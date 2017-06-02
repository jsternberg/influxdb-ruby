module InfluxDB
  module Mixins
    module Enumerable
      def each
        while v = self.next
          yield v
        end
      end
    end
  end
end
