require 'equivalent-xml'
require 'equivalent-xml/rspec_matchers'

describe Sheng::Docx do
  let(:output_file) { "/tmp/sheng_output_document.docx" }
  let(:expected_output_file) { fixture_path("output_document.docx") }
  let(:input_file) { fixture_path("input_document.docx") }
  let(:input_hash) { JSON.parse(File.read(fixture_path("inputs/complete.json"))) }
  let(:mutable_documents) {
    ['word/document.xml', 'word/numbering.xml', 'word/header1.xml']
  }

  subject { described_class.new(input_file, input_hash) }

  describe '#generate' do
    it 'should produce the same document as fixtures output_file' do
      subject.generate(output_file)
      Zip::File.new(output_file).entries.each do |file|
        if mutable_documents.include?(file.name)
          Zip::File.open(output_file) do |zip|
            gem_output_xml      = zip.read(file)
            fixtures_output_xml = Zip::File.new(expected_output_file).read(file)

            expect(gem_output_xml).to be_equivalent_to fixtures_output_xml
          end
        end
      end
    end

    it "should replace all mergefields when given all mergefield values" do
      subject.generate(output_file)
      Zip::File.new(output_file).entries.each do |file|
        if mutable_documents.include?(file.name)
          Zip::File.open(output_file) do |zip|
            xml = zip.read(file)
            expect(Nokogiri::XML(xml).xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]")).to be_empty
          end
        end
      end
    end

    it "should raise an error when one or more mergefields isn't merged" do
      incomplete_hash = JSON.parse(File.read(fixture_path("inputs/incomplete.json")))
      doc = Sheng::Docx.new(input_file, incomplete_hash)
      expect {
        doc.generate(output_file)
      }.to raise_error(Sheng::MergefieldNotReplacedError)
    end

    it "should raise an error when bad document supplied" do
      bad_documents = [
        'with_bad_table.docx',
        'with_extra_field.docx',
        'with_extra_sequence.docx'
      ]
      bad_documents.each do |doc_path|
        doc = Sheng::Docx.new(fixture_path("bad_docx_files/#{doc_path}"), input_hash)
        expect {
          doc.generate(output_file)
        }.to raise_error(Sheng::MergefieldNotReplacedError)
      end
    end

    it 'should raise an error if document has bad (old) mergefields' do
      old_document = fixture_path("bad_docx_files/with_old_mergefields.docx")
      doc = Sheng::Docx.new(old_document, input_hash)
      expect {
        doc.generate(output_file)
      }.to raise_error(Sheng::WMLFile::InvalidWML)
    end
  end

  describe '#new' do
    it "should raise an error if zip file not found" do
      allow(Zip::File).to receive(:new).with('crazy_path').and_raise(Zip::ZipError)
      expect {
        Sheng::Docx.new('crazy_path', {})
      }.to raise_error(Sheng::InputArgumentError)
    end

    it "should raise an ArgumentError if params is not a hash" do
      allow(Sheng::DataSet).to receive(:new).with(:not_a_hash).and_raise(ArgumentError)
      expect {
        Sheng::Docx.new(input_file, :not_a_hash)
      }.to raise_error(ArgumentError)
    end
  end
end
