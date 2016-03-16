module Sheng
  module Filters
    class Base
      attr_reader :value, :method, :arguments

      def initialize(method: method, arguments: [])
        @method = method
        @arguments = arguments
      end

      def self.implements(*names)
        names.each do |name|
          Sheng::Filters.registry.merge!({ name.to_sym => self })
        end
      end

      def filter(value)
        return value unless value.respond_to?(method)
        value.send(method, *arguments)
      end
    end
  end
end