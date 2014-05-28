module Sheng
  class CheckBox
    attr_reader :element

    def initialize(element = nil)
      @element = element
    end

    def key
      @element.xpath('.//w:name').first['w:val']
    end

    def interpolate(data_set)
      value = data_set.fetch(key)
      checked_attribute = @element.search('.//w:default').first.attribute('val')
      checked_attribute.value = value_is_truthy?(value) ? '1' : '0'
    rescue DataSet::KeyNotFound
      # Ignore this error; we'll collect all uninterpolated fields later and
      # raise a new exception, so we can list all the fields in an error
      # message.
      nil
    end

    def value_is_truthy?(value)
      ['true', '1', 'yes'].include? value.to_s.downcase
    end
  end
end
