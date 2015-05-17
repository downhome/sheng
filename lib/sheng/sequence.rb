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

    def add_sequence_element(member, index, last: false)
      if series_with_commas? && index > 0
        @start_field.add_previous_sibling(serial_comma_node(last: last))
      end
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

    def series_with_commas?
      @start_field.series_with_commas?
    end

    def new_tag tag_name
      tag = Nokogiri::XML::Node.new(tag_name, xml_document)
      tag.namespace = xml_document.root.namespace_definitions.find { |ns| ns.prefix == "w" }
      tag
    end

    def serial_comma_node(last: false)
      r_tag = new_tag('r')
      t_tag = new_tag('t')
      t_tag["xml:space"] = "preserve"
      t_tag.content = ", #{last ? 'and ' : ''}"
      r_tag.add_child(t_tag)
      r_tag
    end
  end
end
