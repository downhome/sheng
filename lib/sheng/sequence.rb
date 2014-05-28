module Sheng
  class Sequence < MergeFieldSet
    def initialize(merge_field)
      @start_merge_field = merge_field
      @key = merge_field.key
      @xml_document = merge_field.xml_document
      @start_node, @xml_fragment, @end_node = get_bounds_and_node_set
    end

    def interpolate(data_set)
      collection = data_set.fetch(key)
      if collection.respond_to?(:each_with_index)
        collection.each_with_index do |item, i|
          new_node_set = @start_node.add_previous_sibling(dup_node_set)
          merge_field_set = MergeFieldSet.new("#{key}_#{i}", new_node_set)
          merge_field_set.interpolate(DataSet.new(item))
        end
        @start_node.remove
        @end_node.remove
        xml_fragment.remove
      end
    rescue DataSet::KeyNotFound
      nil
    end

    def is_table_row?
      @start_merge_field.element.ancestors[2].name == 'tr'
    end

    def traverse_up_degrees
      is_table_row? ? 3 : 1
    end

    def get_bounds_and_node_set
      start_node = @start_merge_field.element.ancestors[traverse_up_degrees - 1]
      node_set = Nokogiri::XML::NodeSet.new(start_node.document)
      next_node, end_node = start_node, nil
      while !end_node
        next_node = next_node.next_element
        if next_node.search(".//w:fldSimple[contains(@w:instr, 'end:#{key}')]").present?
          end_node = next_node
        else
          node_set << next_node
        end
      end
      [start_node, node_set, end_node]
    end

    def dup_node_set
      xml_fragment.each_with_object(Nokogiri::XML::NodeSet.new(xml_document)) do |child, dup_content|
        dup_content << child.dup
      end
    end
  end
end
