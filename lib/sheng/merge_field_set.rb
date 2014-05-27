module Sheng
  class MergeFieldSet
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

    def to_tree
      nodes.map do |node|
        hsh = { :type => node.class, :key => node.key }
        if node.is_a? MergeFieldSet
          hsh[:nodes] = node.to_tree
        end
        hsh
      end
    end

    def nodes
      @nodes ||= begin
        current_sequence_key = nil
        basic_nodes.map do |node|
          if node.is_a? MergeField
            if current_sequence_key
              if node.raw_key =~ /^end:/ && node.key == current_sequence_key
                current_sequence_key = nil
              end
              next
            elsif node.raw_key =~ /^start:/
              node = Sequence.new(node)
              current_sequence_key = node.key
            end
          end
          node
        end.compact
      end
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
      xml.xpath(".//#{mergefield_element_path}|.//#{checkbox_element_path}")
    end

    def mergefield_element_path
      "w:fldSimple[contains(@w:instr, 'MERGEFIELD')]"
    end

    def checkbox_element_path
      "w:checkBox/.."
    end
  end
end