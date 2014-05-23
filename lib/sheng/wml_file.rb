module Sheng
  class WMLFile
    class InvalidWML < StandardError; end
    class MergefieldNotReplacedError < StandardError
      def initialize(field_names)
        super("Mergefields not replaced: #{field_names.join(", ")}")
      end
    end

    attr_reader :xml

    def initialize(xml)
      @xml = Nokogiri::XML(xml)
    end

    def interpolate(data_set)
      parent_set.interpolate(data_set)
      check_for_full_interpolation!
      parent_set.xml.to_s
    end

    def check_for_full_interpolation!
      mergefield_path = "//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]"
      unmerged_fields = xml.xpath(mergefield_path).each_with_object([]) do |element, fields|
        fields << element['w:instr'].gsub("MERGEFIELD", "").gsub("\\* MERGEFORMAT", "").strip
      end.uniq

      unless unmerged_fields.empty?
        raise MergefieldNotReplacedError.new(unmerged_fields)
      end
    end

    def parent_set
      @parent_set ||= MergeFieldSet.new('main', xml)
    end

    def to_tree
      parent_set.to_tree
    end

    def validate!
      validate
      raise InvalidWML.new(@errors.inspect) unless @errors.empty?
    end

    def validate
      @errors = []
      bad_fields = xml.xpath('//w:instrText')
      bad_fields.each do |bad_field|
        unless bad_field.text =~ /FORMCHECKBOX/
          @errors << "Bad mergefield: #{bad_field.text}"
        end
      end
    end
  end
end
