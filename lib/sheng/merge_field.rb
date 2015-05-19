module Sheng
  class MergeField
    AllowedFilters = [:upcase, :downcase, :capitalize, :titleize, :reverse]
    InstructionTextRegex = /^\s*MERGEFIELD(.*)\\\* MERGEFORMAT\s*$/
    KeyRegex = /^(start:|end:|if:|end_if:|unless:|end_unless:)?\s*([^\|\s]+)\s*\|?(.*)?/

    class BadMergefieldError < StandardError; end

    attr_reader :element, :xml_document

    def initialize(element)
      @element = element
      @xml_document = element.document
    end

    def new_style?
      element.name == 'fldChar'
    end

    def key
      raw_key.gsub(KeyRegex, '\2')
    end

    def filters
      match = raw_key.match(KeyRegex)
      match.captures[2].split("|").map(&:strip)
    end

    def raw_key
      @raw_key ||= mergefield_instruction_text.gsub(InstructionTextRegex, '\1').strip
    end

    def mergefield_instruction_text
      return element['w:instr'] unless new_style?
      current_element = element.parent.next_element
      label = current_element.at_xpath(".//w:instrText").text
      loop do
        current_element = current_element.next_element
        next if ["bookmarkStart", "bookmarkEnd"].include?(current_element.name)
        label_part = current_element.at_xpath(".//w:instrText")
        break unless label_part
        label << label_part.text
      end
      raise BadMergefieldError.new(label) unless label.match(InstructionTextRegex)
      label
    end

    def styling_paragraph
      return nil if inline?
      containing_element.at_xpath(".//w:pPr")
    end

    def styling_run
      if new_style?
        separator_field = element.ancestors[1].at_xpath(".//w:fldChar[contains(@w:fldCharType, 'separate')]")
        if separator_field
          separator_field.parent.next_element.at_xpath(".//w:rPr")
        end
      else
        element.at_xpath(".//w:rPr")
      end
    end

    def start_key
      if is_start?
        "#{block_prefix}:#{key}"
      elsif block_prefix == "end"
        "start:#{key}"
      else
        "#{block_prefix.gsub(/^end_/, '')}:#{key}"
      end
    end

    def block_type
      return nil unless block_prefix
      if ["start", "end"].include?(block_prefix)
        Sequence
      else
        ConditionalBlock
      end
    end

    def block_prefix
      @potential_prefix ||= begin
        potential_prefix = raw_key.match(KeyRegex).captures[0]
        potential_prefix && potential_prefix.gsub(/\:$/, '')
      end
    end

    def is_start?
      block_prefix && !block_prefix.match(/^end/)
    end

    def iteration_variable
      if filters.detect { |f| f =~ /^as\((.*)\)$/ }
        $1.to_sym
      else
        :item
      end
    end

    def series_with_commas?
      filters.detect { |f| f =~ /^series_with_commas/ }
    end

    def comma_series_conjunction
      if filters.detect { |f| f =~ /^series_with_commas\((.*)\)$/ }
        $1
      else
        "and"
      end
    end

    def is_end?
      block_prefix && block_prefix.match(/^end/)
    end

    def remove
      if inline?
        xml.remove
      elsif is_table_row_marker?
        containing_element.ancestors[1].remove
      else
        containing_element.remove
      end
    end

    def containing_element
      parents_until_container = new_style? ? 2 : 1
      element.ancestors[parents_until_container - 1]
    end

    def is_table_row_marker?
      in_table_row? && (is_start? || is_end?)
    end

    def in_table_row?
      containing_element.ancestors[1] && containing_element.ancestors[1].name == "tr"
    end

    def inline?
      containing_element.children.text != xml.text
    end

    def add_previous_sibling(fragment_to_add)
      if inline?
        [xml].flatten.first.add_previous_sibling(fragment_to_add)
      elsif is_table_row_marker?
        containing_element.ancestors[1].add_previous_sibling(fragment_to_add)
      else
        containing_element.add_previous_sibling(fragment_to_add)
      end
    end

    def next_element
      if inline?
        [xml].flatten.last.next_element
      elsif is_table_row_marker?
        containing_element.ancestors[1].next_element
      else
        containing_element.next_element
      end
    end

    def xml
      return element unless new_style?
      nodeset = Nokogiri::XML::NodeSet.new(xml_document)
      current_node = element.parent
      nodeset << current_node
      loop do
        current_node = current_node.next_element
        nodeset << current_node
        break if current_node.at_xpath("./w:fldChar[contains(@w:fldCharType, 'end')]")
      end
      nodeset
    end

    def replace_mergefield(value)
      new_run = Sheng::Support.new_text_run(
        value, xml_document: xml_document, style_run: styling_run
      )
      xml.before(new_run)
      xml.remove
    end

    def interpolate(data_set)
      value = data_set.fetch(key)
      replace_mergefield(filter_value(value))
    rescue DataSet::KeyNotFound
      # Ignore this error; we'll collect all uninterpolated fields later and
      # raise a new exception, so we can list all the fields in an error
      # message.
      nil
    end

    def filter_value(value)
      filters.inject(value) { |val, filter|
        if AllowedFilters.include?(filter.to_sym) && val.respond_to?(filter.to_sym)
          val.send(filter)
        else
          val
        end
      }
    end
  end
end
