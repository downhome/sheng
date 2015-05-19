module Sheng
  module PathHelpers
    def new_mergefield_element_path
      "w:fldChar[contains(@w:fldCharType, 'begin')]"
    end

    def mergefield_element_path
      "w:fldSimple[contains(@w:instr, 'MERGEFIELD')]"
    end

    def checkbox_element_path
      "w:checkBox/.."
    end
  end
end