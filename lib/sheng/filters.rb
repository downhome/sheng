module Sheng
  module Filters
    class UnsupportedFilterError < StandardError; end

    class << self
      def registry
        @registry ||= {}
      end

      def filter_for(filter_string)
        filter_method, args_list = filter_string.split(/[\(\)]/)
        args = (args_list || "").split(/\s*,\s*/).map { |arg| Sheng::Support.typecast_numeric(arg) }
        filter_class = registry[filter_method.to_sym]
        raise UnsupportedFilterError.new(filter_string) unless filter_class
        filter_class.new(method: filter_method, arguments: args)
      end
    end
  end
end

require_relative "filters/string_filter"
