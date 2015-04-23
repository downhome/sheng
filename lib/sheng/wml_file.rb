module Sheng
  class WMLFile
    class InvalidWML < StandardError; end
    class MergefieldNotReplacedError < StandardError
      def initialize(unmerged_fields)
        unmerged_keys = unmerged_fields.map(&:raw_key)
        super("Mergefields not replaced: #{unmerged_keys.join(', ')}")
      end
    end

    attr_reader :xml, :filename

    def initialize(filename, xml)
      @filename = filename
      @xml = Nokogiri::XML(xml)
    end

    def interpolate(data_set)
      parent_set.interpolate(data_set)
      check_for_full_interpolation!
      parent_set.xml_fragment.to_s
    end

    def check_for_full_interpolation!
      modified_parent_set = MergeFieldSet.new('main', xml)
      unmerged_fields = modified_parent_set.basic_nodes.reject { |node|
        node.is_a?(CheckBox)
      }

      unless unmerged_fields.empty?
        raise MergefieldNotReplacedError.new(unmerged_fields)
      end
    end

    def parent_set
      @parent_set ||= MergeFieldSet.new('main', xml)
    end

    def required_hash
      parent_set.required_hash
    end

    def to_tree
      parent_set.to_tree
    end
  end
end
