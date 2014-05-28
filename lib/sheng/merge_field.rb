module Sheng
  class MergeField
    attr_reader :element, :xml_document

    def initialize(element)
      @element = element
      @xml_document = element.document
    end

    def key
      raw_key.gsub(/^(start:|end:)/, '')
    end

    def raw_key
      raw_key = @element['w:instr'].gsub("MERGEFIELD", "").gsub("\\* MERGEFORMAT", "").strip
    end

    def is_start?
      raw_key =~ /^start:/
    end

    def is_end?
      raw_key =~ /^end:/
    end

    def interpolate(data_set)
      value = data_set.fetch(key)
      @element.replace(new_text_run_node(value))
    rescue DataSet::KeyNotFound
      # Ignore this error; we'll collect all uninterpolated fields later and
      # raise a new exception, so we can list all the fields in an error
      # message.
      nil
    end

    def new_text_run_node value
      r_tag = new_tag('r')
      t_tag = new_tag('t')
      t_tag.content = value
      r_tag.add_child(t_tag)
      r_tag
    end

    def new_tag tag_name
      tag = Nokogiri::XML::Node.new(tag_name, xml_document)
      tag.namespace = xml_document.root.namespace_definitions.find { |ns| ns.prefix == "w" }
      tag
    end
  end
end
