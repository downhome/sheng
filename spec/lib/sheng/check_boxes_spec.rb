describe Sheng::CheckBoxes do
  let(:input_hash) { JSON.parse(input_json).deep_symbolize_keys }
  let(:params) { input_hash[:check_boxes] }
  let(:input_json) { File.open("#{SPEC_ROOT}/fixtures/check_boxes/input.json").read }
  let(:input_xml) { Nokogiri::XML(File.read(fixture_path('check_boxes/input_document.xml'))) }
  let(:output_xml) { File.read(fixture_path('check_boxes/output_document.xml')) }

  describe '#replace' do
    before :each do
      @check_boxes_xml = described_class.new.replace(params, input_xml)
    end

    it "should replace all checkboxes in the document (xml)" do
      get_unmerged_fields(@check_boxes_xml).should == []
    end

    it "generates output xml with replaced values" do
      expect(@check_boxes_xml.to_xml).to eq output_xml
    end

    it "should assume defined strings as 'true'" do
      input_hash['designee_3p'] = 'really true'
      expect(@check_boxes_xml.to_xml).to eq output_xml
    end

    it "should assume nil is 'false'" do
      input_hash['designee_co'] = nil
      expect(@check_boxes_xml.to_xml).to eq output_xml
    end
  end
end
