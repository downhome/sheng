module Sheng
  class DataSet
    def initialize(hsh)
      raise ArgumentError unless hsh.is_a? Hash
      @raw_data_hash = hsh.deep_symbolize_keys
    end

    def fetch(key)
      key_parts = key.split(/\./)
      current_result = @raw_data_hash

      key_parts.each_with_index do |key_part, i|
        value = current_result[key_part.to_sym]
        if (i + 1) < key_parts.length
          raise "Too many parts in key" if !(value.is_a?(Hash))
        end
        current_result = value
      end

      raise "Too few parts in key" if current_result.is_a?(Hash)
      current_result
    end
  end
end
