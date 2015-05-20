module Sheng
  class CheckBox
    attr_reader :element, :xml_document

    def initialize(element = nil)
      @element = element
      @xml_document = element.document
    end

    def key
      @element.xpath('.//w:name').first['w:val']
    end

    def raw_key
      key
    end

    def interpolate(data_set)
      value = data_set.fetch(key)
      checked_attribute = @element.search('.//w:default').first.attribute('val')
      checked_attribute.value = value_is_truthy?(value) ? '1' : '0'
    rescue DataSet::KeyNotFound
      # Ignore this error; if the key for this checkbox is not found in the
      # data set, we don't want to uncheck the checkbox; we just want to leave
      # it alone.
      nil
    end

    def value_is_truthy?(value)
      ['true', '1', 'yes'].include? value.to_s.downcase
    end
  end
end
