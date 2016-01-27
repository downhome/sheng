describe Sheng::MergeField do
  let(:fragment) { xml_fragment('input/merge_field/merge_field') }
  let(:element) { fragment.xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]").first }
  subject { described_class.new(element) }

  describe ".from_element" do
    it "returns a new MergeField for the given element" do
      expect(described_class.from_element(element)).to eq(subject)
    end

    context "when given a new-style non-mergefield" do
      let(:fragment) { xml_fragment('input/merge_field/bad/not_a_real_mergefield_new') }
      let(:element) { fragment.xpath("//w:fldChar[contains(@w:fldCharType, 'begin')]").first }

      it "returns nil" do
        expect(described_class.from_element(element)).to be_nil
      end
    end

    context "when given an old-style non-mergefield" do
      let(:fragment) { xml_fragment('input/merge_field/bad/not_a_real_mergefield_old') }
      let(:element) { fragment.xpath("//w:fldSimple").first }

      it "returns nil" do
        expect(described_class.from_element(element)).to be_nil
      end
    end
  end

  describe "mergefield with math operations" do
    let(:fragment) { xml_fragment('input/merge_field/math_merge_field') }
    let(:element) { fragment.xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]").first }

    describe '#interpolate' do
      it 'interpolates values from dataset into mergefield' do
        dataset = Sheng::DataSet.new({
          :baskets => {
            :count => 2
          },
          :origami => 8
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field/math_merge_field')
      end
    end
  end

  describe "new style merge field" do
    let(:fragment) { xml_fragment('input/merge_field/new_merge_field') }
    let(:element) { fragment.xpath("//w:fldChar[contains(@w:fldCharType, 'begin')]").first }

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
        expect(subject.xml[0]).to eq(element.ancestors[0])
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

      describe ".new" do
        it "raises an exception" do
          expect {
            subject
          }.to raise_error(described_class::NotAMergeFieldError, "MERGEFIELD  this_has_a_beginning_but_no_")
        end
      end
    end

    context "when not an actual mergefield" do
      let(:fragment) { xml_fragment('input/merge_field/bad/not_a_real_mergefield_new') }

      describe ".new" do
        it "raises an exception" do
          expect {
            subject
          }.to raise_error(described_class::NotAMergeFieldError, "PAGE   \\* MERGEFORMAT ")
        end
      end
    end
  end

  describe ".new" do
    context "when not actually a mergefield" do
      let(:fragment) { xml_fragment('input/merge_field/bad/not_a_real_mergefield_old') }
      let(:element) { fragment.xpath("//w:fldSimple").first }

      it "raises an exception" do
        expect {
          subject
        }.to raise_error(described_class::NotAMergeFieldError, " PAGE  \\* MERGEFORMAT ")
      end
    end
  end

  describe "#get_value" do
    let(:dataset) {
      Sheng::DataSet.new({
        :ocean => { :fishy => "scrumblefish" },
        :numbers => { :first => 23, :second => 8 }
      })
    }

    it "returns value from dataset when given simple lookup" do
      allow(subject).to receive(:key).and_return("ocean.fishy")
      expect(subject.get_value(dataset)).to eq("scrumblefish")
    end

    it "performs math operations on values from dataset" do
      allow(subject).to receive(:key).and_return("(numbers.first * numbers.second) + 5")
      expect(subject.get_value(dataset)).to eq(189)
    end

    it "performs math operations with no dataset lookup" do
      allow(subject).to receive(:key).and_return("2 + (3*5)")
      expect(subject.get_value(dataset)).to eq(17)
    end

    it "raises exception if key not found in simple lookup" do
      allow(subject).to receive(:key).and_return("oliver.twist")
      expect {
        subject.get_value(dataset)
      }.to raise_error(Sheng::DataSet::KeyNotFound)
    end

    it "raises exception if key not found in math formula" do
      allow(subject).to receive(:key).and_return("oliver.twist * 15")
      expect {
        subject.get_value(dataset)
      }.to raise_error(Sheng::DataSet::KeyNotFound)
    end

    it "raises exception if interpolated math formula includes invalid symbols" do
      allow(subject).to receive(:key).and_return("ocean.fishy * 15")
      expect {
        subject.get_value(dataset)
      }.to raise_error(Dentaku::UnboundVariableError)
    end
  end

  describe '#interpolate' do
    it 'interpolates filtered values from dataset into mergefield' do
      allow(subject).to receive(:get_value).with(:a_dataset).and_return("scrumblefish")
      allow(subject).to receive(:filter_value).with("scrumblefish").and_return("l33tphish")
      subject.interpolate(:a_dataset)
      expect(subject.xml_document).to be_equivalent_to xml_fragment('output/merge_field/merge_field')
    end

    it "does not replace and returns nil if any keys not found" do
      allow(subject).to receive(:get_value).with(:a_dataset).and_raise(Sheng::DataSet::KeyNotFound)
      expect(subject).to receive(:replace_mergefield).never
      expect(subject.interpolate(:a_dataset)).to be_nil
    end

    it "does not replace and returns nil if calculation error encountered" do
      allow(subject).to receive(:get_value).with(:a_dataset).and_raise(Dentaku::UnboundVariableError.new([]))
      expect(subject).to receive(:replace_mergefield).never
      expect(subject.interpolate(:a_dataset)).to be_nil
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

  describe "#required_variables" do
    it "returns key parts that are not operators or numeric" do
      allow(subject).to receive(:key).and_return("cat.toes   * 15 + (yawns / 2.0)")
      expect(subject.required_variables).to eq(["cat.toes", "yawns"])
    end
  end

  describe "#key_parts" do
    it "returns key split on all word boundaries except dot separators" do
      allow(subject).to receive(:key).and_return("cat.toes   * 15 + (yawns / 2.0)")
      expect(subject.key_parts).to eq(["cat.toes", "*", "15", "+", "(", "yawns", "/", "2.0", ")"])
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

    it 'returns key even if it contains math operations' do
      allow(subject).to receive(:raw_key).and_return("whumpies * 3 | cook | dress(frock)")
      expect(subject.key).to eq 'whumpies * 3'
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