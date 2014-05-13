module Sheng
  class Sequences < Sheng::ReplacerBase
    def replace params, xml
      params.each do |sequence_name, sequence_values|
        template_set = get_node_set(sequence_name, xml)

        if template_set.first
          first_element = find_element("//#{path("start_#{sequence_name}")}", xml).parent
          last_element = find_element("//#{path("end_#{sequence_name}")}", xml).parent

          sequence_values.each do |hash|
            new_node_set = first_element.add_previous_sibling(dup_node_set(template_set, xml))
            new_node_set.after(new_tag("p", xml))

            hash.each do |key, value|
              new_node_set.xpath(".//#{path(key)}", xml).each do |element|
                replacement_tag =  new_label_node(value, xml)
                element.replace(replacement_tag)
              end
            end
          end

          template_set.remove
          first_element.remove
          last_element.remove
        end
      end
      xml
    end
  end
end
