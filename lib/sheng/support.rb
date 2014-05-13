module Sheng
  # Support methods for utility functionality such as string modification -
  # could also be accomplished by monkey-patching String class.
  module Support
    module_function

    def symbolize_keys(hash)
      {}.tap do |result|
        hash.each do |key, value|
          result[key.to_sym] = case value
          when Hash then symbolize_keys(value)
          when Array then
            value.map do |v|
              symbolize_keys(v)
            end
          else
            value
          end
        end
      end
    end
  end
end
