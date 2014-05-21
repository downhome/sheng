module Sheng
  class WMLFile
    def initialize(xml)
      @xml = xml
    end

    def interpolate(data_set)
      parent_set = MergeFieldSet.new('main', Nokogiri::XML(@xml))
      parent_set.interpolate(data_set)
      parent_set.xml.to_s
    end
  end
end
