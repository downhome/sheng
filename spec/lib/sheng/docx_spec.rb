describe Sheng::Docx do

  include_context "lets"

  context 'json input' do
    it 'should produce the same document as fixtures output_file' do
      doc.generate(output_file)
      fixtures_output_dox_file.entries.each do |file|
        if mutable_documents.include?(file.name)
          gem_output_xml      = Zip::File.new( output_file ).read(file)
          fixtures_output_xml = fixtures_output_dox_file.read(file)

          gem_output_xml.should eq(gem_output_xml)
        end
      end
    end
  end

  context 'hash input' do
    it 'should produce the same document for input fields as hash' do
      doc = Sheng::Docx.new(
        File.open("#{SPEC_ROOT}/fixtures/input_document.docx"),
        JSON.parse(File.open("#{SPEC_ROOT}/fixtures/input.json").read) )

      doc.generate(output_file)
      fixtures_output_dox_file.entries.each do |file|
        if mutable_documents.include?(file.name)
          gem_output_xml      = Zip::File.new( output_file ).read(file)
          fixtures_output_xml = fixtures_output_dox_file.read(file)

          gem_output_xml.should eq(gem_output_xml)
        end
      end
    end
  end

  it "should replace all mergefields when given all mergefield values" do
    doc.generate(output_file)
    fixtures_input_dox_file.entries.each do |file|
      if mutable_documents.include?(file.name)
        xml = Zip::File.new( output_file ).read(file)

        Nokogiri::XML( xml ).xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]").empty?.should be(true)
      end
    end
  end

  it "should create new.docx file after execution" do
    doc.generate("#{SPEC_ROOT}/fixtures/tmp_output_document.docx")

    File.exist?("#{SPEC_ROOT}/fixtures/tmp_output_document.docx").should be(true)
  end
end