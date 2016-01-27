describe Sheng::MergeFieldSet do
  let(:fragment) { xml_fragment('input/merge_field_set/merge_field_set') }
  subject { described_class.new('key', fragment) }

  describe '#interpolate' do
    it 'iterates through nodes and calls interpolate on each' do
      node1, node2 = double('Node'), double('Node')
      expect(node1).to receive(:interpolate).with(:the_data_set)
      expect(node2).to receive(:interpolate).with(:the_data_set)
      allow(subject).to receive(:nodes).and_return([node1, node2])
      subject.interpolate(:the_data_set)
    end

    context "with fields that are not valid mergefields" do
      let(:fragment) { xml_fragment('input/merge_field_set/with_non_mergefield_fields') }

      it "ignores the non-mergefield fields and interpolates the rest" do
        dataset = Sheng::DataSet.new({ :color => "browns" })

        subject.interpolate(dataset)
        expect(subject.xml_fragment).to be_equivalent_to xml_fragment('output/merge_field_set/with_non_mergefield_fields')
      end
    end

    it 'returns expected interpolated fragment' do
      dataset = Sheng::DataSet.new({
        :person => {
          :first_name => 'Brad',
          :last_name => 'Tucklemoof',
          :socks => [
            { :color => 'Green', :size => 'Stumungous', :dimensions => { :width => 14, :height => 5 } },
            { :color => 'Whitish', :size => 'Teensy', :dimensions => { :width => 28, :height => 13 } }
          ]
        },
        :veggies => { :green => { :spinach => true } }
      })

      subject.interpolate(dataset)
      expect(subject.xml_fragment).to be_equivalent_to xml_fragment('output/merge_field_set/merge_field_set')
    end

    context "with complex nesting and reuse" do
      let(:fragment) { xml_fragment('input/merge_field_set/complex_nesting_and_reuse') }
      it 'works' do
        dataset = Sheng::DataSet.new({
          :people => [
            {
              :first_name => "Bringo",
              :last_name => "Brango",
              :favorites => {
                :color => "Ghost",
                :numbers => [1, "maybe", 0],
                :loves_candy => false
              }
            },
            {
              :first_name => "Uncle",
              :last_name => "Hork",
              :favorites => {
                :color => "Xi",
                :numbers => ["unicorn", "paper"],
                :loves_candy => true
              }
            }
          ],
          :frogs => [
            {
              :warts => "bioluminescent",
              :legs => "yak",
              :feelings => ["insignificant", "worthless"]
            },
            {
              :warts => 198,
              :legs => "silky smooth",
              :feelings => ["stylish", "nap"]
            }
          ],
          :king => {
            :house => {
              :windows => "bony",
              :doors => "pig"
            }
          }
        })

        subject.interpolate(dataset)
        expect(subject.xml_fragment).to be_equivalent_to xml_fragment('output/merge_field_set/complex_nesting_and_reuse')
      end
    end
  end

  describe '#to_tree' do
    it 'returns array of nodes for set, with nested sequences' do
      expect(subject.to_tree).to eq tree_fixture('merge_field_set')
    end

    it 'returns proper tree with embedded sequence' do
      subject = described_class.new('key', xml_fragment('input/sequence/embedded_sequence'))
      expect(subject.to_tree).to eq tree_fixture('embedded_sequence')
    end

    it 'throws exception if sequence missing end tag' do
      subject = described_class.new('key', xml_fragment('input/sequence/bad/unclosed_sequence'))
      expect {
        subject.to_tree
      }.to raise_error(Sheng::Sequence::MissingEndTag, "no end tag for start:library.books")
    end

    it 'throws exception if sequence nesting is wrong' do
      subject = described_class.new('key', xml_fragment('input/sequence/bad/badly_nested_sequence'))
      expect {
        subject.to_tree
      }.to raise_error(Sheng::Sequence::ImproperNesting, "expected end tag for start:birds, got end:animals")
    end
  end

  describe '#required_hash' do
    it 'returns skeleton hash demonstrating required data for interpolation' do
      expect(subject.required_hash).to eq({
        "person" => {
          "first_name" => nil,
          "last_name" => nil,
          "socks" => [
            {
              "color" => nil,
              "size" => nil,
              "dimensions" => {
                "width" => nil,
                "height" => nil
              }
            }
          ]
        },
        "veggies"=> {
          "green" => {
            "spinach" => nil
          }
        }
      })
    end

    it 'uses given value as placeholder for mergefields/checkboxes' do
      expect(subject.required_hash(:foo)).to eq({
        "person" => {
          "first_name" => :foo,
          "last_name" => :foo,
          "socks" => [
            {
              "color" => :foo,
              "size" => :foo,
              "dimensions" => {
                "width" => :foo,
                "height" => :foo
              }
            }
          ]
        },
        "veggies"=> {
          "green" => {
            "spinach" => :foo
          }
        }
      })
    end

    context "with multiple blocks using the same variable" do
      let(:fragment) { xml_fragment('input/merge_field_set/complex_nesting_and_reuse') }

      it 'properly merges all requirements when multiple blocks reuse the same variable' do
        expect(subject.required_hash).to eq({
          "people" => [
            {
              "first_name" => nil,
              "last_name" => nil,
              "favorites" => {
                "color" => nil,
                "numbers" => [],
                "loves_candy" => nil
              }
            }
          ],
          "frogs" => [
            {
              "warts" => nil,
              "legs" => nil,
              "feelings" => []
            }
          ],
          "king" => {
            "house" => {
              "windows" => nil,
              "doors" => nil
            }
          }
        })
      end
    end
  end
end
