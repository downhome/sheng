module XMLHelper
  def xml_fragment(type, gsub: {})
    path = fixture_path("xml_fragments/#{type}.xml")
    xml = File.read(path)
    gsub.each do |key, value|
      xml.gsub!(key, value)
    end
    Nokogiri::XML(xml) { |config| config.noblanks }
  end

  def fragment_with_checked_box(fragment)
    Nokogiri::XML(fragment.to_s.gsub(/default w:val="."/, 'default w:val="1"'))
  end

  def fragment_with_unchecked_box(fragment)
    Nokogiri::XML(fragment.to_s.gsub(/default w:val="."/, 'default w:val="0"'))
  end
end
