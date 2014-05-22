module Sheng
  class CheckBox
    include Sheng::Helpers
    attr_reader :element

    def initialize(element = nil)
      @element = element
    end

    def key
      @element.xpath('.//w:name').first['w:val']
    end

    def interpolate(data_set)
      if value = data_set.fetch(key)
        checked_attribute = @element.search('.//w:default').first.attribute('val')
        checked_attribute.value = '1' if value.to_s == 'true'
      end
    end
  end
end
