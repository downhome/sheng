shared_context "lets" do

  let(:doc) do 
    Gutenberg::Docx.new( File.open("#{SPEC_ROOT}/fixtures/input_document.docx"), File.open("#{SPEC_ROOT}/fixtures/input.json").read )
  end

  let(:xml) do
    Nokogiri::XML(fixtures_input_dox_file.read("word/document.xml"))
  end

  let(:mergefields) do
    ["first_name", "last_name", "a_long_paragraph", "table_identifier_1", "meal", "drink", "appetizer", "dessert", "start_owner_signature", "end_owner_signature"]
  end

  let(:mutable_documents) do 
    ['word/document.xml', 'word/numbering.xml', 'word/header1.xml']
  end

  let(:doc_from_file) do
    Gutenberg::Docx.new( "#{SPEC_ROOT}/fixtures/input_document.docx", File.open("#{SPEC_ROOT}/fixtures/input.json").read )
  end

  let(:fixtures_input_dox_file) do 
    Zip::File.new( "#{SPEC_ROOT}/fixtures/input_document.docx" ) 
  end

  let(:fixtures_output_dox_file) do 
    Zip::File.new( "#{SPEC_ROOT}/fixtures/output_document.docx" ) 
  end

  let(:broken_json) do
    File.open("#{SPEC_ROOT}/fixtures/broken_input.json").read 
  end

  let(:input_json) do
    File.open("#{SPEC_ROOT}/fixtures/input.json").read 
  end

  let(:input_docx) do
    File.open("#{SPEC_ROOT}/fixtures/input_document.docx") 
  end

  let(:output_file) do 
    "#{SPEC_ROOT}/fixtures/tmp_output_document.docx"
  end

  let(:input_xml) do
    File.open("#{SPEC_ROOT}/fixtures/document.xml") 
  end

  let(:output_xml) do 
    File.open("#{SPEC_ROOT}/fixtures/output_document.xml") 
  end

  let(:bad_documents) do
    [
      "#{SPEC_ROOT}/fixtures/input_document_with_bad_table.docx",
      "#{SPEC_ROOT}/fixtures/input_document_with_extra_field.docx",
      "#{SPEC_ROOT}/fixtures/input_document_with_extra_sequence.docx"
    ]
  end

  after(:all) do
    if File.exist?( output_file )
      File.delete( output_file )
    end
  end

end