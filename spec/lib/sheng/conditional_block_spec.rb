describe Sheng::ConditionalBlock do
  let(:fragment) { xml_fragment('input/conditional_block/conditional_block_if') }
  let(:element) { fragment.xpath("//w:instrText").first }
  let(:merge_field) { Sheng::MergeField.new(element) }
  subject { described_class.new(merge_field) }

  describe '#interpolate' do
    let(:fragment) { xml_fragment('input/conditional_block/conditional_block_inline') }

    context "inline" do
      it 'includes if sections when variable truthy' do
        dataset = Sheng::DataSet.new({
          :alicorns => 'so tasties'
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/inline_exists')
      end

      it 'removes entire section if variable falsy' do
        dataset = Sheng::DataSet.new({})

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/inline_does_not_exist')
      end
    end

    context "with if block" do
      let(:fragment) { xml_fragment('input/conditional_block/conditional_block_if') }

      it 'includes sections when variable truthy' do
        dataset = Sheng::DataSet.new({
          :alicorns => 'so tasties'
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/if_exists')
      end

      it 'removes entire section if variable falsy' do
        dataset = Sheng::DataSet.new({})

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/if_does_not_exist')
      end
    end

    context "with unless block" do
      let(:fragment) { xml_fragment('input/conditional_block/conditional_block_unless') }

      it 'includes sections when variable falsy' do
        dataset = Sheng::DataSet.new({})

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/unless_does_not_exist')
      end

      it 'removes entire section if variable truthy' do
        dataset = Sheng::DataSet.new({
          :alicorns => 'so tasties'
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/unless_exists')
      end
    end

    context "within a table" do
      let(:fragment) { xml_fragment('input/conditional_block/conditional_in_table') }
      let(:dataset_hash) {
        {
          :include_dogs => true,
          :dog_favorites => [
            { :name => "Fluffy the Android", :megaphone => "YellTheBest" },
            { :name => "Derek Dog", :megaphone => "Super Primo Loudkins" }
          ]
        }
      }

      it "includes if rows when variable truthy" do
        dataset = Sheng::DataSet.new(dataset_hash)

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/conditional_in_table_exists')
      end

      it "removes entire section when variable falsy" do
        dataset = Sheng::DataSet.new(dataset_hash.merge(:include_dogs => false))

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/conditional_in_table_does_not_exist')
      end
    end

    context "with an embedded conditional" do
      let(:fragment) { xml_fragment('input/conditional_block/embedded_conditional') }
      let(:dataset_hash) {
        { :alicorns => true, :scubas => true }
      }

      it "includes both sections when both are truthy" do
        dataset = Sheng::DataSet.new(dataset_hash)

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/embedded_conditional_both')
      end

      it "includes only outside section if inside falsy" do
        dataset = Sheng::DataSet.new(dataset_hash.merge(:scubas => false))

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/embedded_conditional_outside')
      end

      it "ignores truthy inside section if outside section is falsy" do
        dataset = Sheng::DataSet.new(dataset_hash.merge(:alicorns => false))

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/conditional_block/embedded_conditional_inside')
      end
    end
  end

  describe '#new' do
    context "with unclosed conditional" do
      let(:fragment) { xml_fragment('input/conditional_block/bad/unclosed_conditional') }
      it 'raises an exception indicating the missing end tag' do
        dataset = Sheng::DataSet.new({})
        expect {
          subject
        }.to raise_error(described_class::MissingEndTag, "no end tag for if:alicorns")
      end
    end

    context "with badly nested conditional" do
      let(:fragment) { xml_fragment('input/conditional_block/bad/badly_nested_conditional') }
      it 'raises an exception indicating the nesting issue' do
        dataset = Sheng::DataSet.new({})
        expect {
          subject
        }.to raise_error(described_class::ImproperNesting, "expected end tag for unless:pumpkins, got end_if:alicorns")
      end
    end
  end
end
