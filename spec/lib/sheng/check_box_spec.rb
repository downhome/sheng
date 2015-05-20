describe Sheng::CheckBox do
  let(:fragment) { xml_fragment('input/check_box/check_box') }
  let(:element) { fragment.at_xpath(".//w:checkBox/..") }
  subject { described_class.new(element) }

  describe '#key' do
    it 'returns w:val attribute of w:name node in xml fragment' do
      expect(subject.key).to eq 'goats'
    end
  end

  describe '#raw_key' do
    it 'returns key' do
      expect(subject.raw_key).to eq subject.key
    end
  end

  describe '#value_is_truthy?' do
    context 'given truthy values' do
      ['true', 'TRuE', true, 1, '1', 'yes'].each do |truthy|
        given_key = truthy.is_a?(String) ? "'#{truthy}' (as string)" : truthy
        it "returns true if key is #{given_key} in dataset" do
          expect(subject.value_is_truthy?(truthy)).to be_truthy
        end
      end
    end

    context 'given falsy values' do
      ['false', 'FaLSE', false, 0, '0', 'no', '', nil].each do |falsy|
        given_key = falsy.is_a?(String) ? "'#{falsy}' (as string)" : falsy
        given_key = 'nil' if falsy.nil?
        it "returns false if key is #{given_key} in dataset" do
          expect(subject.value_is_truthy?(falsy)).to be_falsy
        end
      end
    end
  end

  describe '#interpolate' do
    let(:dataset) { Sheng::DataSet.new('goats' => 'foofle') }

    it "checks the checkbox if key is truthy in dataset" do
      allow(subject).to receive(:value_is_truthy?).with('foofle').and_return(true)
      subject.interpolate(dataset)
      expect(subject.xml_document).to be_equivalent_to xml_fragment('output/check_box/check_box')
    end

    it "does not check the checkbox if key is falsy in dataset" do
      allow(subject).to receive(:value_is_truthy?).with('foofle').and_return(false)
      subject.interpolate(dataset)
      expect(subject.xml_document).to be_equivalent_to fragment_with_unchecked_box(subject.xml_document)
    end

    it "does not uncheck a default checked checkbox if key is truthy in dataset" do
      default_checked = described_class.new(fragment_with_checked_box(subject.xml_document))
      allow(default_checked).to receive(:value_is_truthy?).with('foofle').and_return(true)
      default_checked.interpolate(dataset)
      expect(default_checked.xml_document).to be_equivalent_to xml_fragment('output/check_box/check_box')
    end

    it "unchecks a default checked checkbox if key is falsy in dataset" do
      default_checked = described_class.new(fragment_with_checked_box(subject.xml_document))
      allow(default_checked).to receive(:value_is_truthy?).with('foofle').and_return(false)
      default_checked.interpolate(dataset)
      expect(default_checked.xml_document).to be_equivalent_to fragment_with_unchecked_box(default_checked.xml_document)
    end

    it "does not check the checkbox if key is not found in dataset" do
      dataset = Sheng::DataSet.new({})
      subject.interpolate(dataset)
      expect(subject.xml_document).to be_equivalent_to fragment_with_unchecked_box(subject.xml_document)
    end

    it "does not uncheck a checked checkbox if key is not found in dataset" do
      dataset = Sheng::DataSet.new({})
      default_checked = described_class.new(fragment_with_checked_box(subject.xml_document))
      default_checked.interpolate(dataset)
      expect(default_checked.xml_document).to be_equivalent_to xml_fragment('output/check_box/check_box')
    end
  end
end
