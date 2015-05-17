module Sheng
  class Block < MergeFieldSet
    class MissingEndTag < StandardError; end
    class ImproperNesting < StandardError; end

    def initialize(merge_field)
      @start_field = merge_field
      @key = merge_field.key
      @xml_document = merge_field.xml_document
      @xml_fragment, @end_field = get_node_set_and_end_field
    end

    def extract_mergefields(fragment)
      if fragment.name == "fldSimple"
        return [MergeField.new(fragment)]
      end
      fragment.xpath(".//#{mergefield_element_path}|.//#{new_mergefield_element_path}").map do |field_simple|
        MergeField.new(field_simple)
      end
    end

    def get_node_set_and_end_field
      node_set = Nokogiri::XML::NodeSet.new(@start_field.xml_document)
      next_node, end_field = @start_field, nil
      embedded_starts = [@start_field]
      while !end_field
        next_node = next_node.next_element

        if next_node.nil?
          raise MissingEndTag, "no end tag for #{@start_field.block_prefix}:#{key}"
        end

        extract_mergefields(next_node).each do |mergefield|
          if mergefield.is_start?
            embedded_starts.push mergefield
          elsif mergefield.is_end?
            last_start = embedded_starts.pop
            if last_start.key != mergefield.key
              raise ImproperNesting, "expected end tag for #{last_start.block_prefix}:#{last_start.key}, got #{mergefield.block_prefix}:#{mergefield.key}"
            elsif embedded_starts.empty?
              end_field = mergefield
            end
          end
        end

        if end_field
          if end_field.inline? && end_field.new_style?
            node_set.pop
          end
        else
          node_set << next_node
        end
      end
      [node_set, end_field]
    end
  end
end