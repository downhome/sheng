module Sheng
  class Tables < Sheng::ReplacerBase
    def replace params, xml
      params.each do |table_name, values|
        identifier = find_element("//w:tr[.//#{path(table_name)}]", xml)
        if identifier
          pattern = identifier.next_element
          values.each do |hash|
            table_row = pattern.dup
            hash.each do |key, value|
              parent_node = table_row.xpath(".//#{path(key)}").first
              parent_node.replace(new_label_node(value, xml)) unless parent_node.nil?
            end
            identifier.parent.add_child(table_row)
          end
          identifier.remove
          pattern.remove
        end
      end
      xml
    end
  end
end
