class Sheng::MergeField
  include Sheng::Helpers
  attr_reader :element

  def initialize(element = nil)
    @element = element
  end

  def key
    raw_key.gsub(/^(start_|end_)/, '')
  end

  def raw_key
    raw_key = @element['w:instr'].gsub("MERGEFIELD", "").gsub("\\* MERGEFORMAT", "").strip
  end

  def xml
    @element.document
  end

  def interpolate(data_set)
    value = data_set.fetch(key)
    @element.replace(new_text_run_node(value)) if value
  end

  def new_text_run_node value
    r_tag = new_tag('r', xml)
    t_tag = new_tag('t', xml)
    t_tag.content = value
    r_tag.add_child(t_tag)
    r_tag
  end
end
