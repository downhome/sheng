module XMLHelper
  def xml_fragment(type)
    path = fixture_path("xml_fragments/#{type}.xml")
    Nokogiri::XML(File.open(path)) { |config| config.noblanks }
  end

  def fragment_with_checked_box(fragment)
    Nokogiri::XML(fragment.to_s.gsub(/default w:val="."/, 'default w:val="1"'))
  end

  def fragment_with_unchecked_box(fragment)
    Nokogiri::XML(fragment.to_s.gsub(/default w:val="."/, 'default w:val="0"'))
  end
end
