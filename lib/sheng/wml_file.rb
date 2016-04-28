module Sheng
  class WMLFile
    class InvalidWML < Docx::TemplateError; end

    attr_reader :xml, :filename, :errors

    def initialize(filename, xml)
      @filename = filename
      @xml = Nokogiri::XML(xml)
      @errors = {}
    end

    def interpolate(data_set)
      parent_set.interpolate(data_set)
      errors.merge!(parent_set.errors)
      parent_set.xml_fragment.to_s
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
