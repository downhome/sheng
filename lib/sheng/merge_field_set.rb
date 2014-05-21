module Sheng
  class MergeFieldSet
    include Sheng::Helpers
    attr_reader :xml, :key

    def initialize(key, xml)
      @key = key
      @xml = xml
    end

    def interpolate(data_set)
      nodes.each do |node|
        node.interpolate(data_set)
      end
    end

    def nodes
      current_sequence_key = nil
      basic_nodes.map do |node|
        if node.is_a? MergeField
          if current_sequence_key
            if node.raw_key =~ /^end_/ && node.key == current_sequence_key
              current_sequence_key = nil
            end
            next
          elsif node.raw_key =~ /^start_/
            node = Sheng::Sequence.new(node)
            current_sequence_key = node.key
          end
        end
        node
      end.compact
    end

    def basic_nodes
      basic_node_elements.map { |element|
        if element.xpath('.//w:checkBox').first
          CheckBox.new(element)
        else
          MergeField.new(element)
        end
      }
    end

    def basic_node_elements
      find_elements(".//#{mergefield_element_path}|.//#{checkbox_element_path}", xml)
    end

    def mergefield_element_path(key = nil)
      "w:fldSimple[contains(@w:instr, '#{key}') and contains(@w:instr, 'MERGEFIELD')]"
    end

    def checkbox_element_path(key = nil)
      "w:checkBox/../w:name[contains(@w:val, '#{key}')]/.."
    end
  end
end
