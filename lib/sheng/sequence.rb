require_relative "block"

module Sheng
  class Sequence < Block
    def interpolate(data_set)
      collection = data_set.fetch(key)
      if collection.respond_to?(:each_with_index)
        collection.each_with_index do |item, i|
          add_sequence_element(item, i)
        end
        clean_up
      end
    rescue DataSet::KeyNotFound
      nil
    end

    def add_sequence_element(member, index)
      new_node_set = @start_field.add_previous_sibling(dup_node_set)
      merge_field_set = MergeFieldSet.new("#{key}_#{index}", new_node_set)
      member = { @start_field.iteration_variable => member } unless member.is_a?(Hash)
      merge_field_set.interpolate(DataSet.new(member))
    end

    def clean_up
      [@start_field, @end_field, xml_fragment].map(&:remove)
    end

    def dup_node_set
      xml_fragment.each_with_object(Nokogiri::XML::NodeSet.new(xml_document)) do |child, dup_content|
        dup_content << child.dup
      end
    end
  end
end
