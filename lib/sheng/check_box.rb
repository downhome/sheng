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
      checked_attribute = @element.search('.//w:default').first.attribute('val')
      checked_attribute.value = '1' if data_set.fetch(key).to_s == 'true'
    end
  end
end
