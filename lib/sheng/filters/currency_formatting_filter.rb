require_relative "base"

module Sheng
  module Filters
    class CurrencyFormattingFilter < Base
      implements :currency

      def filter(value)
        return value unless Sheng::Support.is_numeric?(value)
        integer, fractional = ("%00.2f" % value).split(".")
        integer.reverse!.gsub!(/(\d{3})(?=\d)/, '\\1,').reverse!
        "#{arguments.first}#{integer}.#{fractional}"
      end
    end
  end
end