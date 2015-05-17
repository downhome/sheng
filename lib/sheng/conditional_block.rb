require_relative "block"

module Sheng
  class ConditionalBlock < Block
    def interpolate(data_set)
      variable = data_set.fetch(key, :default => nil)
      @start_field.remove
      @end_field.remove
      if criterion_met?(variable)
        merge_field_set = MergeFieldSet.new("#{conditional_type}_#{key}", xml_fragment)
        merge_field_set.interpolate(data_set)
      else
        xml_fragment.remove
      end
    end

    def conditional_type
      @start_field.block_prefix
    end

    def criterion_met?(variable)
      variable_exists = variable && (variable == true || !variable.empty?)
      if conditional_type == "if"
        variable_exists
      else
        !variable_exists
      end
    end
  end
end
