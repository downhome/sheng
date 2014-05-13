module Sheng
  class Strings < Sheng::ReplacerBase
    def replace params, xml
      params.each do |k, v|
        find_elements("//#{path(k)}", xml).each do |element|
          element.replace( new_label_node(v, xml) )
        end
      end
      xml
    end
  end
end
