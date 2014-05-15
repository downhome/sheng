describe Sheng::Tables do
  let(:input_json) { File.open("#{SPEC_ROOT}/fixtures/tables/input.json").read }
  let(:input_hash) { Sheng::Support.symbolize_keys(JSON.parse(input_json)) }
  let(:params) { input_hash[:tables] }
  let(:input_xml) { Nokogiri::XML(File.read(fixture_path('tables/input_document.xml'))) }
  let(:output_xml) { File.read(fixture_path('tables/output_document.xml')) }

  describe '#replace' do
    before :each do
      @tables_xml = described_class.new.replace(params, input_xml)
    end

    it "should replace all sequence keys in the document (xml)" do
      get_unmerged_fields(@tables_xml).should == ['project_amt']
    end

    it "generates output xml with replaced values" do
      expect(@tables_xml.to_xml).to eq output_xml
    end
  end

end
