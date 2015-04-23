describe Sheng::Docx do
  let(:output_file) { "/tmp/sheng_output_document.docx" }
  let(:expected_output_file) { fixture_path("docx_files/output_document.docx") }
  let(:input_file) { fixture_path("docx_files/input_document.docx") }
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

    describe "with older style mergefields" do
      let(:expected_output_file) { fixture_path("docx_files/old_style/output_document.docx") }
      let(:input_file) { fixture_path("docx_files/old_style/input_document.docx") }

      it 'still works' do
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
      doc = described_class.new(input_file, incomplete_hash)
      expect {
        doc.generate(output_file)
      }.to raise_error(Sheng::WMLFile::MergefieldNotReplacedError, "Mergefields not replaced: first_name, last_name")
    end

    shared_examples_for 'a bad document' do |filename, error, error_message = nil|
      it "should raise #{error} when given #{filename}" do
        doc = described_class.new(fixture_path("bad_docx_files/#{filename}"), input_hash)
        expect {
          doc.generate(output_file)
        }.to raise_error(error, error_message)
      end
    end

    it_should_behave_like 'a bad document', 'with_field_not_in_dataset.docx',
      Sheng::WMLFile::MergefieldNotReplacedError

    it_should_behave_like 'a bad document', 'with_unended_sequence.docx',
      Sheng::Sequence::MissingEndTag, "no end tag for sequence: owner_signature"

    it_should_behave_like 'a bad document', 'with_missing_sequence_start.docx',
      Sheng::WMLFile::MergefieldNotReplacedError

    it_should_behave_like 'a bad document', 'with_poorly_nested_sequences.docx',
      Sheng::Sequence::ImproperNesting, "expected end:birds, got end:animals"
  end

  describe '#new' do
    it "should raise an error if zip file not found" do
      allow(Zip::File).to receive(:new).with('crazy_path').and_raise(Zip::ZipError)
      expect {
        described_class.new('crazy_path', {})
      }.to raise_error(described_class::InvalidFile, "Zip::ZipError")
    end

    it "should raise an ArgumentError if params is not a hash" do
      allow(Sheng::DataSet).to receive(:new).with(:not_a_hash).and_raise(ArgumentError)
      expect {
        described_class.new(input_file, :not_a_hash)
      }.to raise_error(ArgumentError)
    end
  end

  context 'with fake document' do
    let(:zip_double) {
      entry1 = double(Zip::Entry, :name => 'word/document.xml', :get_input_stream => :document)
      entry2 = double(Zip::Entry, :name => 'word/footer2.xml', :get_input_stream => :footer2)
      entry3 = double(Zip::Entry, :name => 'not_wml.xml', :get_input_stream => :not_wml)

      double(Zip::File, :entries => [entry1, entry2, entry3])
    }
    subject { described_class.new('a_fake_file.docx', {}) }

    before(:each) do
      allow(Sheng::WMLFile).to receive(:new).with('word/document.xml', :document).
        and_return(double(:filename => 'word/document.xml', :to_tree => :document_tree, :required_hash => { :a => { :b => 1 } }))
      allow(Sheng::WMLFile).to receive(:new).with('word/footer2.xml', :footer2).
        and_return(double(:filename => 'word/footer2.xml', :to_tree => :footer2_tree, :required_hash => { :a => { :c => 2 } }))
      allow(Zip::File).to receive(:new).with('a_fake_file.docx').and_return(zip_double)
    end

    describe '#to_tree' do
      it "returns trees for every WML file in document" do
        expect(subject.to_tree).to eq([
          { :file => 'word/document.xml', :tree => :document_tree },
          { :file => 'word/footer2.xml', :tree => :footer2_tree }
        ])
      end
    end

    describe '#required_hash' do
      it "returns deep merged #required_hash values from all WML files" do
        expect(subject.required_hash).to eq({
          :a => { :b => 1, :c => 2 }
        })
      end
    end
  end
end
