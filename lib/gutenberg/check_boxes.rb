module Gutenberg
  class CheckBoxes < Gutenberg::ReplacerBase
    def replace params, xml
      params.each do |k, v|
        find_elements("//w:name[contains(@w:val, '#{k}')]", xml).each do |element|          
          value = v ? "1" : "0"

          new_node = Nokogiri::XML::Node.new('checked', xml)
          new_node.set_attribute("val", value)

          element.parent.search("//w:default").first.attribute("val").value = value
          element.parent.search("//w:checkBox").first.add_child(new_node)
        end
      end
      xml
    end
  end
end