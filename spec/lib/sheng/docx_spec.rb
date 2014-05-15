require 'equivalent-xml'
require 'equivalent-xml/rspec_matchers'

describe Sheng::Docx do

  include_context "lets"

  context 'json input' do
    it 'should produce the same document as fixtures output_file' do
      pending "This test does not pass; XML is not equivalent"
      doc.generate(output_file)
      fixtures_output_docx_file.entries.each do |file|
        if mutable_documents.include?(file.name)
          Zip::File.open(output_file) do |zip|
            gem_output_xml      = zip.read(file)
            fixtures_output_xml = fixtures_output_docx_file.read(file)

            expect(gem_output_xml).to be_equivalent_to fixtures_output_xml
          end
        end
      end
    end
  end

  context 'hash input' do
    it 'should produce the same document for input fields as hash' do
      pending "This test does not pass; XML is not equivalent"
      doc = Sheng::Docx.new(
        File.open("#{SPEC_ROOT}/fixtures/input_document.docx"),
        JSON.parse(File.open("#{SPEC_ROOT}/fixtures/input.json").read) )

      doc.generate(output_file)
      fixtures_output_docx_file.entries.each do |file|
        if mutable_documents.include?(file.name)
          Zip::File.open(output_file) do |zip|
            gem_output_xml      = zip.read(file)
            fixtures_output_xml = fixtures_output_docx_file.read(file)

            expect(gem_output_xml).to be_equivalent_to fixtures_output_xml
          end
        end
      end
    end
  end

  it "should replace all mergefields when given all mergefield values" do
    doc.generate(output_file)
    fixtures_input_docx_file.entries.each do |file|
      if mutable_documents.include?(file.name)
        Zip::File.open(output_file) do |zip|
          xml = zip.read(file)
          expect(Nokogiri::XML(xml).xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]")).to be_empty
        end
      end
    end
  end

  it "should create new.docx file after execution" do
    doc.generate("#{SPEC_ROOT}/fixtures/tmp_output_document.docx")

    File.exist?("#{SPEC_ROOT}/fixtures/tmp_output_document.docx").should be(true)
  end
end
