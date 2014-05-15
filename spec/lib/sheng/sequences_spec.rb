require 'spec_helper'
describe Sheng::Sequences do
  let(:input_hash) { Sheng::Support.symbolize_keys(JSON.parse(input_json)) }
  let(:params) { input_hash[:sequences] }
  let(:input_json) { File.open("#{SPEC_ROOT}/fixtures/sequences/input.json").read }
  let(:input_xml) { Nokogiri::XML(File.read(fixture_path('sequences/input_document.xml'))) }
  let(:output_xml) { File.read(fixture_path('sequences/output_document.xml')) }

  describe '#replace' do
    before :each do
      @sequences_xml = described_class.new.replace(params, input_xml)
    end

    it "should replace all sequence keys in the document (xml)" do
      get_unmerged_fields(@sequences_xml).should == []
    end

    it "generates output xml with replaced values" do
      expect(@sequences_xml.to_xml).to eq output_xml
    end
  end

end
