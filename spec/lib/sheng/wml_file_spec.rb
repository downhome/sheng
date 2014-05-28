describe Sheng::WMLFile do
  describe '#xml' do
    it 'returns initialized xml parsed with nokogiri' do
      allow(Nokogiri).to receive(:XML).with(:the_xml).and_return(:yay_xml)
      subject = described_class.new('yak_soup', :the_xml)
      expect(subject.xml).to eq :yay_xml
    end
  end

  describe '#parent_set' do
    it "returns mergefield set for entire document" do
      subject = described_class.new('yak_soup', 'whatever')
      allow(subject).to receive(:xml).and_return(:boy_i_love_xml)
      allow(Sheng::MergeFieldSet).to receive(:new).
        with('main', :boy_i_love_xml).
        and_return(:the_mama_of_all_sets)
      expect(subject.parent_set).to eq :the_mama_of_all_sets
    end
  end

  describe '#to_tree' do
    it "delegates to #parent_set" do
      subject = described_class.new('yak_soup', 'whatever')
      allow(subject).to receive(:parent_set).
        and_return(double(:to_tree => :this_is_cooler_than_a_poem))
      expect(subject.to_tree).to eq :this_is_cooler_than_a_poem
    end
  end

  describe '#required_hash' do
    it "delegates to #parent_set" do
      subject = described_class.new('yak_soup', 'whatever')
      allow(subject).to receive(:parent_set).
        and_return(double(:required_hash => :brown_and_crispy))
      expect(subject.required_hash).to eq :brown_and_crispy
    end
  end
end
