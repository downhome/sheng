require_relative "block"

module Sheng
  class Sequence < Block
    def interpolate(data_set)
      collection = data_set.fetch(key)
      if collection.respond_to?(:each_with_index)
        collection.each_with_index do |item, i|
          add_sequence_element(item, i, last: i == collection.length - 1)
        end
        clean_up
      end
    rescue DataSet::KeyNotFound
      nil
    end

    def array_of_primitives_expected?
      return true if nodes.map(&:key).uniq == ["item"]
      @start_field.iteration_variable != :item
    end

    def add_sequence_element(member, index, last: false)
      if series_with_commas? && index > 0
        @start_field.add_previous_sibling(serial_comma_node(index, last: last))
      end
      new_node_set = @start_field.add_previous_sibling(dup_node_set)
      merge_field_set = MergeFieldSet.new("#{key}_#{index}", new_node_set)
      member = { @start_field.iteration_variable => member } unless member.is_a?(Hash)
      merge_field_set.interpolate(DataSet.new(member))
      if index == 0 || last
        copy_section_formatting(new_node_set, side: last ? "end" : "start")
      end
    end

    def copy_section_formatting(node_set, side:)
      field = instance_variable_get(:"@#{side}_field")
      if field.styling_paragraph && field.styling_paragraph.at_xpath(".//w:sectPr")
        existing_ppr = node_set.at_xpath(".//w:pPr")
        existing_ppr && existing_ppr.remove
        node_set.first.prepend_child(field.styling_paragraph.dup)
      end
    end

    def clean_up
      [@start_field, @end_field, xml_fragment].map(&:remove)
    end

    def dup_node_set
      xml_fragment.each_with_object(Nokogiri::XML::NodeSet.new(xml_document)) do |child, dup_content|
        dup_content << child.dup
      end
    end

    def series_with_commas?
      @start_field.series_with_commas?
    end

    def serial_comma_node(index, last: false)
      content = ", #{last ? "#{@start_field.comma_series_conjunction} " : ""}"
      content.gsub!(/\,/, '') if last && index == 1
      Sheng::Support.new_text_run(
        content, xml_document: xml_document, space_preserve: true
      )
    end
  end
end
