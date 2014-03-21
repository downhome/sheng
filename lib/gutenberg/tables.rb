module Gutenberg
  class Tables < Gutenberg::ReplacerBase
    def replace params, xml
      params.each do |k, v|
        identifier = find_element("//w:tr[.//#{path(k)}]", xml)
        if identifier
          patern = identifier.next
          v.each do |hash|
            table_row = patern.dup
            hash.each do |key, value|
              parent_node = table_row.xpath(".//#{path(key)}").first
              parent_node.replace(new_label_node(value, xml))
            end
            identifier.parent.add_child(table_row)
          end
          identifier.remove
          patern.remove
        end
      end
      xml
    end
  end
end