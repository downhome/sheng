module Sheng
  class Sequence < MergeFieldSet
    class MissingEndTag < StandardError; end
    class ImproperNesting < StandardError; end

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
      if @start_merge_field.new_style?
        @start_merge_field.element.ancestors[3].name == 'tr'
      else
        @start_merge_field.element.ancestors[2].name == 'tr'
      end
    end

    def traverse_up_degrees
      degrees = is_table_row? ? 3 : 1
      if @start_merge_field.new_style?
        degrees + 1
      else
        degrees
      end
    end

    def get_bounds_and_node_set
      start_node = @start_merge_field.element.ancestors[traverse_up_degrees - 1]
      node_set = Nokogiri::XML::NodeSet.new(start_node.document)
      next_node, end_node = start_node, nil
      embedded_sequences = [key]
      while !end_node
        next_node = next_node.next_element

        if next_node.nil?
          raise MissingEndTag, "no end tag for sequence: #{key}"
        end

        extract_mergefields(next_node).each do |mergefield|
          if mergefield.is_start?
            embedded_sequences.push mergefield.key
          elsif mergefield.is_end?
            if (last_sequence = embedded_sequences.pop) && last_sequence != mergefield.key
              raise ImproperNesting, "expected end:#{last_sequence}, got end:#{mergefield.key}"
            end
          end
        end

        if embedded_sequences.empty?
          end_node = next_node
        else
          node_set << next_node
        end
      end
      [start_node, node_set, end_node]
    end

    def extract_mergefields(fragment)
      fragment.xpath(".//#{mergefield_element_path}|.//#{new_mergefield_element_path}").map do |field_simple|
        MergeField.new(field_simple)
      end
    end

    def dup_node_set
      xml_fragment.each_with_object(Nokogiri::XML::NodeSet.new(xml_document)) do |child, dup_content|
        dup_content << child.dup
      end
    end
  end
end
