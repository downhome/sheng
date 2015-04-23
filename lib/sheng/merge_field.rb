module Sheng
  class MergeField
    attr_reader :element, :xml_document

    def initialize(element)
      @element = element
      @xml_document = element.document
    end

    def new_style?
      element.name == 'instrText'
    end

    def key
      raw_key.gsub(/^(start:|end:)|(\s+.*)/, '')
    end

    def filters
      match = raw_key.match(/\|(.*)$/)
      if match
        match.captures[0].split("|").map(&:strip)
      else
        []
      end
    end

    def raw_key
      mergefield_instruction_text.gsub(/MERGEFIELD|\\\* MERGEFORMAT/, "").strip
    end

    def mergefield_instruction_text
      return element['w:instr'] unless new_style?
      current_element = element
      label = current_element.text
      loop do
        current_element = current_element.parent.next_element.at_xpath('./w:instrText')
        break unless current_element
        label << current_element.text
      end
      label
    end

    def styling_paragraph
      if new_style?
        separator_field = element.ancestors[1].at_xpath(".//w:fldChar[contains(@w:fldCharType, 'separate')]")
        if separator_field
          separator_field.parent.next_element.at_xpath(".//w:rPr")
        end
      else
        element.at_xpath(".//w:rPr")
      end
    end

    def is_start?
      raw_key =~ /^start:/
    end

    def iteration_variable
      if filters.detect { |f| f =~ /^as\((.*)\)/ }
        $1.to_sym
      else
        :item
      end
    end

    def is_end?
      raw_key =~ /^end:/
    end

    def replace_mergefield(value)
      if !new_style?
        element.replace(new_text_run_node(value))
      else
        nodeset = Nokogiri::XML::NodeSet.new(xml_document)
        current_node = element.parent.previous_element
        nodeset << current_node
        loop do
          current_node = current_node.next_element
          nodeset << current_node
          break if current_node.at_xpath("./w:fldChar[contains(@w:fldCharType, 'end')]")
        end
        nodeset.before(new_text_run_node(value))
        nodeset.remove
      end
    end

    def interpolate(data_set)
      value = data_set.fetch(key)
      replace_mergefield(value)
    rescue DataSet::KeyNotFound
      # Ignore this error; we'll collect all uninterpolated fields later and
      # raise a new exception, so we can list all the fields in an error
      # message.
      nil
    end

    def new_text_run_node value
      r_tag = new_tag('r')
      if styling_paragraph
        r_tag.add_child(styling_paragraph)
      end
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
