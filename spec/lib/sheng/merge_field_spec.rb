describe Sheng::MergeField do
  subject {
    fragment = xml_fragment('input/merge_field')
    element = fragment.xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]").first
    described_class.new(element)
  }

  describe "new style merge field" do
    subject {
      fragment = xml_fragment('input/new_merge_field')
      element = fragment.xpath("//w:instrText").first
      described_class.new(element)
    }

    describe '#interpolate' do
      it 'interpolates values from dataset into mergefield' do
        dataset = Sheng::DataSet.new({
          :ocean => { :fishy => "scrumblefish" }
        })

        allow(subject).to receive(:filter_value).with("scrumblefish").and_return("l33tphish")
        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field')
      end
    end
  end

  describe '#interpolate' do
    it 'interpolates filtered values from dataset into mergefield' do
      dataset = Sheng::DataSet.new({
        :ocean => { :fishy => "scrumblefish" }
      })

      allow(subject).to receive(:filter_value).with("scrumblefish").and_return("l33tphish")
      subject.interpolate(dataset)
      expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field')
    end
  end

  describe '#raw_key' do
    it 'returns the mergefield name from the element' do
      expect(subject.raw_key).to eq 'ocean.fishy'
    end
  end

  describe '#key' do
    it 'returns the raw key with start metadata stripped off' do
      allow(subject).to receive(:raw_key).and_return('start:whipple.dooter')
      expect(subject.key).to eq 'whipple.dooter'
    end

    it 'returns the raw key with end metadata stripped off' do
      allow(subject).to receive(:raw_key).and_return('end:smock.fortuna')
      expect(subject.key).to eq 'smock.fortuna'
    end

    it 'returns the raw key with filters stripped off' do
      allow(subject).to receive(:raw_key).and_return("whumpies | cook | dress(frock)")
      expect(subject.key).to eq 'whumpies'
    end

    it 'returns the raw key as is if no start or end token' do
      allow(subject).to receive(:raw_key).and_return('ouch_i_hate.frisbees')
      expect(subject.key).to eq 'ouch_i_hate.frisbees'
    end
  end

  describe "#filters" do
    it "returns filters extracted from raw_key" do
      allow(subject).to receive(:raw_key).and_return("whumpies | cook | dress(frock)")
      expect(subject.filters).to eq(["cook", "dress(frock)"])
    end
  end

  describe "#filter_value" do
    it "can upcase" do
      allow(subject).to receive(:filters).and_return(["upcase"])
      expect(subject.filter_value("HorSes")).to eq("HORSES")
    end

    it "can downcase" do
      allow(subject).to receive(:filters).and_return(["downcase"])
      expect(subject.filter_value("HorSes")).to eq("horses")
    end

    it "can reverse" do
      allow(subject).to receive(:filters).and_return(["reverse"])
      expect(subject.filter_value("Maple")).to eq("elpaM")
    end

    it "can titleize" do
      allow(subject).to receive(:filters).and_return(["titleize"])
      expect(subject.filter_value("ribbons are grand")).to eq("Ribbons Are Grand")
    end

    it "can capitalize" do
      allow(subject).to receive(:filters).and_return(["capitalize"])
      expect(subject.filter_value("ribbons are grand")).to eq("Ribbons are grand")
    end

    it "works with multiple filters" do
      allow(subject).to receive(:filters).and_return(["reverse", "capitalize"])
      expect(subject.filter_value("maple")).to eq("Elpam")
    end

    it "does nothing if filter not recognized" do
      allow(subject).to receive(:filters).and_return(["elephantize"])
      expect(subject.filter_value("ribbons are grand")).to eq("ribbons are grand")
    end
  end

  describe "#iteration_variable" do
    it "returns :item" do
      expect(subject.iteration_variable).to eq(:item)
    end

    it "can be overridden with an 'as' filter" do
      allow(subject).to receive(:raw_key).and_return("lunch.parts | as(tasties)")
      expect(subject.iteration_variable).to eq(:tasties)
    end
  end
end