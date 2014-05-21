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
    @element.ancestors.last
  end

  def interpolate(data_set)
    value = data_set.fetch(key)
    @element.replace(new_text_run_node(value))
  end

  def new_text_run_node value
    r_tag = new_tag('r')
    t_tag = new_tag('t')
    t_tag.content = value
    r_tag.add_child(t_tag)
    r_tag
  end

  def new_tag tag_name
    tag = Nokogiri::XML::Node.new(tag_name, xml)
    tag.namespace = xml.document.root.namespace_definitions.find { |ns| ns.prefix == "w" }
    tag
  end
end
