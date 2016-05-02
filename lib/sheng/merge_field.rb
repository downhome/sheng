require "dentaku"

module Sheng
  class MergeField
    MATH_TOKENS = %w[+ - / * ( )]
    REGEXES = {
      instruction_text: /^\s*MERGEFIELD(.*)\\\* MERGEFORMAT\s*$/,
      key_string: /^(?<prefix>start:|end:|if:|end_if:|unless:|end_unless:)?\s*(?<key>[^\|]+)\s*\|?(?<filters>.*)?/
    }

    class NotAMergeFieldError < Sheng::Error; end

    class << self
      def from_element(element)
        new(element)
      rescue NotAMergeFieldError => e
        nil
      end
    end

    attr_reader :element, :xml_document, :errors

    def initialize(element)
      @element = element
      @xml_document = element.document
      @instruction_text = Sheng::Support.extract_mergefield_instruction_text(element)
      @errors = []
    end

    def ==(other)
      other.is_a?(self.class) && other.element == element
    end

    def new_style?
      element.name == 'fldChar'
    end

    def key
      raw_key.match(REGEXES[:key_string])[:key].strip
    end

    def filters
      match = raw_key.match(REGEXES[:key_string])
      match[:filters].split("|").map(&:strip)
    end

    def raw_key
      @raw_key ||= @instruction_text.gsub(REGEXES[:instruction_text], '\1').strip
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
        potential_prefix = raw_key.match(REGEXES[:key_string])[:prefix]
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
      value_as_string = if value.is_a?(BigDecimal)
        value.to_s("F")
      else
        value.to_s
      end

      new_run = Sheng::Support.new_text_run(
        value_as_string, xml_document: xml_document, style_run: styling_run
      )
      xml.before(new_run)
      xml.remove
    end

    def key_parts
      @key_parts ||= key.gsub(",", "").
        gsub(".", "_DOTSEPARATOR_").
        split(/\b|\s/).
        map(&:strip).
        reject(&:empty?).
        map { |token|
          token.gsub("_DOTSEPARATOR_", ".")
        }
    end

    def required_variables
      key_parts.reject { |token|
        Support.is_numeric?(token) || MATH_TOKENS.include?(token)
      }
    end

    def required_hash(placeholder: nil)
      required_variables.inject({}) { |assembled, variable|
        parts = variable.split(/\./)
        last_key = parts.pop
        hash = parts.reverse.inject(last_key => placeholder) do |memo, key|
          memo = { key => memo }; memo
        end
        Sheng::Support.merge_required_hashes(assembled, hash)
      }
    end

    def key_has_math?
      !(MATH_TOKENS & key_parts).empty?
    end

    def get_value(data_set)
      interpolated_string = key_parts.map { |token|
        if Support.is_numeric?(token) || MATH_TOKENS.include?(token)
          token
        else
          data_set.fetch(token)
        end
      }.join(" ")

      return interpolated_string unless key_has_math?

      Dentaku::Calculator.new.evaluate!(interpolated_string.gsub(",", ""))
    end

    def interpolate(data_set)
      value = get_value(data_set)
      replace_mergefield(filter_value(value))
    rescue DataSet::KeyNotFound, Dentaku::UnboundVariableError, Filters::UnsupportedFilterError => e
      @errors << e
      # Ignore this error; we'll collect all uninterpolated fields later and
      # raise a new exception, so we can list all the fields in an error
      # message.
      nil
    end

    def filter_value(value)
      filters.inject(value) { |val, filter_string|
        filterer = Filters.filter_for(filter_string)
        filterer.filter(val)
      }
    end
  end
end
