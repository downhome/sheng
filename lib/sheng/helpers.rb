module Sheng
  module Helpers
    def path key
      "w:fldSimple[contains(@w:instr, '#{key}') and contains(@w:instr, 'MERGEFIELD')]"
    end

    def dup_node_set template_set, xml
      template_set.each_with_object(Nokogiri::XML::NodeSet.new(xml)) do |child, dup_content|
        dup_content << child.dup
      end
    end

    def find_element criteria, xml
      find_elements(criteria, xml).first
    end

    def find_elements criteria, xml
      xml.xpath(criteria)
    end

    def get_unmerged_fields xml
      fields = find_elements("//#{path('')}", xml).each_with_object([]) do |element, fields|
        fields << element['w:instr'].gsub("MERGEFIELD", "").gsub("\\* MERGEFORMAT", "").strip
      end.uniq
    end
  end
end
