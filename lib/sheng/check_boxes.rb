module Sheng
  class CheckBoxes < Sheng::ReplacerBase
    def replace params, xml
      params.each do |checkbox_name, checked|
        find_check_boxes(checkbox_name, xml).each do |element|
          default_attribute = element.parent.search(".//w:default").first.attribute("val")
          default_attribute.value = checked ? "1" : "0"
        end
      end
      xml
    end

    private
    def find_check_boxes(checkbox_name, xml)
      find_elements("//w:ffData/w:name[contains(@w:val, '#{checkbox_name}')]", xml)
        .reject {|e| e.parent.xpath('.//w:checkBox').empty? }
    end
  end
end
