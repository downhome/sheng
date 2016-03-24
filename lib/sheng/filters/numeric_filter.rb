require_relative "base"

module Sheng
  module Filters
    class NumericFilter < Base
      implements :round, :floor

      def filter(value)
        value = Sheng::Support.typecast_numeric(value)
        super
      end
    end
  end
end