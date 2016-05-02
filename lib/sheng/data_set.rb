module Sheng
  class DataSet
    class KeyNotFound < Sheng::Error; end

    attr_accessor :raw_hash

    def initialize(hsh)
      raise ArgumentError.new("must be initialized with a Hash") unless hsh.is_a?(Hash)
      @raw_hash = hsh.deep_symbolize_keys
    end

    def raise_key_too_long(key, key_part)
      raise KeyNotFound, "in #{key}, #{key_part} did not return a Hash"
    end

    def raise_key_too_short(key)
      raise KeyNotFound, "result at #{key} is a Hash"
    end

    def fetch(key, **options)
      raise ArgumentError.new("must provide a string") unless key.is_a?(String)
      key_parts = key.split(/\./)
      current_result = raw_hash

      key_parts.each_with_index do |key_part, i|
        begin
          value = current_result.fetch(key_part.to_sym)
        rescue KeyError
          if options.has_key?(:default)
            value = options[:default]
          else
            raise KeyNotFound, "#{key} (at #{key_part})"
          end
        end
        if (i + 1) < key_parts.length
          raise_key_too_long(key, key_part) if !(value.is_a?(Hash))
        end
        current_result = value
      end

      raise_key_too_short(key) if current_result.is_a?(Hash)
      current_result
    end
  end
end
