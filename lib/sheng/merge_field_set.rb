module Sheng
  class MergeFieldSet
    attr_reader :xml_fragment, :xml_document, :key

    def initialize(key, xml_fragment)
      @key = key
      @xml_fragment = xml_fragment
      @xml_document = xml_fragment.document
    end

    def interpolate(data_set)
      nodes.each do |node|
        node.interpolate(data_set)
      end
    end

    def to_tree
      nodes.map do |node|
        hsh = { :type => node.class.name.underscore.gsub(/^sheng\//, ''), :key => node.key }
        if node.is_a? MergeFieldSet
          hsh[:nodes] = node.to_tree
        end
        hsh
      end
    end

    def required_hash(placeholder = nil)
      nodes.inject({}) do |node_list, node|
        value = node.is_a?(Sequence) ? [node.required_hash(placeholder)] : placeholder
        key_parts = node.key.split(/\./)
        last_key = key_parts.pop
        hsh = key_parts.reverse.inject(last_key => value) do |memo, key|
          memo = { key => memo }; memo
        end
        node_list.deep_merge(hsh)
      end
    end

    # Returns an array of nodes for interpolation, which can be a mix of
    # MergeField, CheckBox, and Sequence instances.
    def nodes
      @nodes ||= begin
        current_sequence_key = nil
        basic_nodes.map do |node|
          if node.is_a? MergeField
            if current_sequence_key
              if node.is_end? && node.key == current_sequence_key
                current_sequence_key = nil
              end
              next
            elsif node.is_start?
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
      xml_fragment.xpath(".//#{mergefield_element_path}|.//#{checkbox_element_path}")
    end

    def mergefield_element_path
      "w:fldSimple[contains(@w:instr, 'MERGEFIELD')]"
    end

    def checkbox_element_path
      "w:checkBox/.."
    end
  end
end
