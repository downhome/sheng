module Sheng
  class Sequences < Sheng::ReplacerBase
    def replace params, xml
      params.each do |k, v|
        template_set = get_node_set(k, xml)

        if template_set.first
          first_element = find_element("//#{path("start_#{k}")}", xml).parent
          last_element = find_element("//#{path("end_#{k}")}", xml).parent

          v.each do |hash|
            new_node_set = first_element.add_previous_sibling(dup_node_set(template_set, xml))
            new_node_set.after(new_tag("p", xml))

            hash.each do |key, value|
              new_node_set.xpath("./#{path(key)}", xml).each{|element| element.replace(new_label_node(value, xml)) }
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
