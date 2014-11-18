module Sheng
  class WMLFile
    include MergeFieldPathHelper
    class InvalidWML < StandardError; end
    class MergefieldNotReplacedError < StandardError
      def initialize(field_names)
        super("Mergefields not replaced: #{field_names.join(", ")}")
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
      mergefield_path = "#{mergefield_element_path}|#{old_style_mergefield_element_path}"
      unmerged_fields = xml.xpath(mergefield_path).each_with_object([]) do |element, fields|
        fields << MergeField.new(element).raw_key
      end.uniq

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
