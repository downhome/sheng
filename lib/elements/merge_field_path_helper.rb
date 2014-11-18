module MergeFieldPathHelper
  def mergefield_element_path
    ".//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]"
  end

  def old_style_mergefield_element_path
    ".//w:instrText[ contains(., 'MERGEFIELD') ]"
  end

  def checkbox_element_path
    ".//w:checkBox/.."
  end
end
