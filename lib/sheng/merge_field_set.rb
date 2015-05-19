require_relative "path_helpers"

module Sheng
  class MergeFieldSet
    include PathHelpers

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
        hsh = {
          :type => node.class.name.underscore.gsub(/^sheng\//, ''),
          :key => node.raw_key
        }
        if node.is_a? MergeFieldSet
          hsh[:nodes] = node.to_tree
        end
        hsh
      end
    end

    def required_hash(placeholder = nil)
      return nil if is_a?(Sequence) && array_of_primitives_expected?
      nodes.inject({}) do |node_list, node|
        hsh = if node.is_a?(ConditionalBlock)
          node.required_hash(placeholder)
        else
          value = node.is_a?(Block) ? [node.required_hash(placeholder)].compact : placeholder
          key_parts = node.key.split(/\./)
          last_key = key_parts.pop
          key_parts.reverse.inject(last_key => value) do |memo, key|
            memo = { key => memo }; memo
          end
        end
        Sheng::Support.merge_required_hashes(node_list, hsh)
      end
    end

    # Returns an array of nodes for interpolation, which can be a mix of
    # MergeField, CheckBox, ConditionalBlock, and Sequence instances.
    def nodes
      @nodes ||= begin
        current_block_key = nil
        basic_nodes.map do |node|
          next if node.is_a?(CheckBox) && current_block_key
          if node.is_a? MergeField
            if current_block_key
              if node.is_end? && node.start_key == current_block_key
                current_block_key = nil
              end
              next
            elsif node.is_start?
              current_block_key = node.start_key
              node = node.block_type.new(node)
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
      child_nodes = xml_fragment.xpath(".//#{mergefield_element_path}|.//#{new_mergefield_element_path}|.//#{checkbox_element_path}").to_a
      child_nodes += xml_fragment.select { |element| element.name == "fldSimple" }
      child_nodes
    end
  end
end
