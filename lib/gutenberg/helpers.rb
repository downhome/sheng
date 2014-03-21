module Gutenberg
  module Helpers
    extend ActiveSupport::Concern

    def path key
      "w:fldSimple[contains(@w:instr, '#{key}') and contains(@w:instr, 'MERGEFIELD')]"
    end

    def dup_node_set template_set, xml
      template_set.each_with_object(Nokogiri::XML::NodeSet.new(xml)) do |child, dup_content|
        dup_content << child.dup
      end 
    end

    def new_tag tag_name, xml
      tag = Nokogiri::XML::Node.new(tag_name, xml)
      tag.namespace = xml.root.namespace_definitions.find{|ns| ns.prefix == "w"}
      tag
    end

    def new_label_node value, xml
      r_tag = new_tag('r', xml)
      t_tag = new_tag('t', xml)
      t_tag.content = value
      r_tag.add_child(t_tag)
      r_tag
    end

    def find_element criteria, xml
      find_elements(criteria, xml).first
    end

    def find_elements criteria, xml
      xml.xpath(criteria)
    end

    def get_node_set criteria, xml
      start_element = "//w:fldSimple[contains(@w:instr, 'start_#{criteria}')]/.."
      end_element = "//w:fldSimple[contains(@w:instr, 'end_#{criteria}')]/.."
      template_set = find_elements("#{start_element}/following-sibling::node()[count(.|#{end_element}/
                                    preceding-sibling::node())=count(#{end_element}/preceding-sibling::node())]", xml)
    end

    def get_unmerged_fields xml
      fields = find_elements("//#{path('')}", xml).each_with_object([]) do |element, fields|
        fields << element['w:instr'].gsub("MERGEFIELD", "").gsub("\\* MERGEFORMAT", "").strip
      end.uniq
    end
  end
end