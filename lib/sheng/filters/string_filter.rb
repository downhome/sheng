require_relative "base"

module Sheng
  module Filters
    class StringFilter < Base
      implements :upcase, :downcase, :capitalize, :titleize, :reverse
    end
  end
end