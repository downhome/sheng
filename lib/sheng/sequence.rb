module Sheng
  class Sequence < MergeFieldSet
    def initialize(merge_field)
      @merge_field = merge_field
      @key = merge_field.key
      @xml = get_node_set(merge_field.xml)
    end

    def interpolate(data_set)
      collection = data_set.fetch(key)
      collection.each_with_index do |item, i|
        new_node_set = xml.first.add_previous_sibling(dup_node_set(xml, xml.first.document))
        merge_field_set = MergeFieldSet.new("#{key}_#{i}", new_node_set)
        merge_field_set.interpolate(Sheng::DataSet.new(item))
      end
      xml.document.search(end_element_path).remove
      xml.document.search(start_element_path).remove
      xml.remove
    end

    def traverse_up_degrees
      @merge_field.element.ancestors[2].name == 'tr' ? 3 : 1
    end

    def get_node_set(merge_field_xml)
      start_scope = "#{start_element_path}/following-sibling::node()"
      end_scope = "#{end_element_path}/preceding-sibling::node()"
      template_set = @merge_field.xml.xpath("#{start_scope}[count(.|#{end_scope})=count(#{end_scope})]")
    end

    def start_element_path
      "//w:fldSimple[contains(@w:instr, 'start_#{key}')]#{'/..' * traverse_up_degrees}"
    end

    def end_element_path
      "//w:fldSimple[contains(@w:instr, 'end_#{key}')]#{'/..' * traverse_up_degrees}"
    end
  end
end
