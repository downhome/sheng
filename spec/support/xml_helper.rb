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

  def in_mutable_wml_files(zip_file)
    Zip::File.new(zip_file).entries.each do |file|
      if Sheng::Docx::WMLFileNamePatterns.any? { |regex| file.name.match(regex) }
        Zip::File.open(zip_file) do |zip|
          yield(file.name, zip.read(file))
        end
      end
    end
  end
end
