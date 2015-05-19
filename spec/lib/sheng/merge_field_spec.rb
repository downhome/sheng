describe Sheng::MergeField do
  let(:fragment) { xml_fragment('input/merge_field/merge_field') }
  let(:element) { fragment.xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]").first }
  subject { described_class.new(element) }

  describe "new style merge field" do
    let(:fragment) { xml_fragment('input/merge_field/new_merge_field') }
    let(:element) { fragment.xpath("//w:instrText").first }

    describe '#raw_key' do
      it 'returns the mergefield name from the element' do
        expect(subject.raw_key).to eq 'ocean.fishy'
      end
    end

    describe '#interpolate' do
      it 'interpolates values from dataset into mergefield' do
        dataset = Sheng::DataSet.new({
          :ocean => { :fishy => "scrumblefish" }
        })

        allow(subject).to receive(:filter_value).with("scrumblefish").and_return("l33tphish")
        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field/merge_field')
      end
    end

    describe "#xml" do
      it "returns full nodeset surrounding element" do
        expect(subject.xml.count).to eq(5)
        expect(subject.xml[1]).to eq(element.ancestors[0])
      end
    end

    describe "with split mergefield instruction text runs" do
      let(:fragment) { xml_fragment('input/merge_field/split_merge_field') }

      describe '#interpolate' do
        it 'works' do
          dataset = Sheng::DataSet.new({
            :persimmon_face => "Lavender"
          })

          subject.interpolate(dataset)
          expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field/split_merge_field')
        end
      end
    end

    describe "with mergefields in line with other text" do
      let(:fragment) { xml_fragment('input/merge_field/inline_merge_field') }

      describe '#interpolate' do
        it 'works' do
          dataset = Sheng::DataSet.new({
            :prefix => "snuffle"
          })

          subject.interpolate(dataset)
          expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field/inline_merge_field')
        end
      end
    end

    describe "with badly formed mergefield tags" do
      let(:fragment) { xml_fragment('input/merge_field/bad/unclosed_merge_field') }

      describe "#interpolate" do
        it "raises an exception" do
          expect {
            subject.interpolate({})
          }.to raise_error(described_class::BadMergefieldError, "MERGEFIELD  this_has_a_beginning_but_no_")
        end
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
      expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field/merge_field')
    end
  end

  describe "#xml" do
    it "returns element" do
      expect(subject.xml).to eq(subject.element)
    end
  end

  describe '#raw_key' do
    it 'returns the mergefield name from the element' do
      expect(subject.raw_key).to eq 'ocean.fishy'
    end
  end

  describe '#key' do
    it 'returns the raw key with start/end metadata stripped off' do
      allow(subject).to receive(:raw_key).and_return('start:whipple.dooter')
      expect(subject.key).to eq 'whipple.dooter'
      allow(subject).to receive(:raw_key).and_return('end:smunch.dooter')
      expect(subject.key).to eq 'smunch.dooter'
    end

    it 'returns the raw key with filters stripped off' do
      allow(subject).to receive(:raw_key).and_return("whumpies | cook | dress(frock)")
      expect(subject.key).to eq 'whumpies'
    end
  end

  describe "#filters" do
    it "returns filters extracted from raw_key" do
      allow(subject).to receive(:raw_key).and_return("whumpies | cook | dress(frock)")
      expect(subject.filters).to eq(["cook", "dress(frock)"])
    end

    it "doesn't care about whitespace" do
      allow(subject).to receive(:raw_key).and_return("whumpies|cook|dress(frock)")
      expect(subject.filters).to eq(["cook", "dress(frock)"])
    end

    it "returns empty array if no filters in raw key" do
      allow(subject).to receive(:raw_key).and_return("whatever.this.is")
      expect(subject.filters).to eq([])
    end
  end

  describe "#is_start?" do
    it "returns true if mergefield is start of block" do
      allow(subject).to receive(:raw_key).and_return("start:whatever")
      expect(subject.is_start?).to be_truthy
      allow(subject).to receive(:raw_key).and_return("if:whatever")
      expect(subject.is_start?).to be_truthy
      allow(subject).to receive(:raw_key).and_return("unless:whatever")
      expect(subject.is_start?).to be_truthy
    end

    it "returns false if mergefield is end of block" do
      allow(subject).to receive(:raw_key).and_return("end:whatever")
      expect(subject.is_start?).to be_falsy
    end

    it "returns false if mergefield is not a block bracket" do
      allow(subject).to receive(:raw_key).and_return("whatever")
      expect(subject.is_start?).to be_falsy
    end
  end

  describe "#is_end?" do
    it "returns true if mergefield is end of block" do
      allow(subject).to receive(:raw_key).and_return("end:whatever")
      expect(subject.is_end?).to be_truthy
      allow(subject).to receive(:raw_key).and_return("end_if:whatever")
      expect(subject.is_end?).to be_truthy
      allow(subject).to receive(:raw_key).and_return("end_unless:whatever")
      expect(subject.is_end?).to be_truthy
    end

    it "returns false if mergefield is start of block" do
      allow(subject).to receive(:raw_key).and_return("start:whatever")
      expect(subject.is_end?).to be_falsy
    end

    it "returns false if mergefield is not a block bracket" do
      allow(subject).to receive(:raw_key).and_return("whatever")
      expect(subject.is_end?).to be_falsy
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

    it "does nothing if value doesn't respond to filter" do
      allow(subject).to receive(:filters).and_return(["upcase"])
      expect(subject.filter_value(130)).to eq(130)
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