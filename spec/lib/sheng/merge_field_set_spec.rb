describe Sheng::MergeFieldSet do
  subject { described_class.new('key', xml_fragment('input/merge_field_set/merge_field_set')) }

  describe '#interpolate' do
    it 'iterates through nodes and calls interpolate on each' do
      node1, node2 = double('Node'), double('Node')
      expect(node1).to receive(:interpolate).with(:the_data_set)
      expect(node2).to receive(:interpolate).with(:the_data_set)
      allow(subject).to receive(:nodes).and_return([node1, node2])
      subject.interpolate(:the_data_set)
    end

    it 'returns expected interpolated fragment' do
      dataset = Sheng::DataSet.new({
        :person => {
          :first_name => 'Brad',
          :last_name => 'Tucklemoof',
          :socks => [
            { :color => 'Green', :size => 'Stumungous' },
            { :color => 'Whitish', :size => 'Teensy' }
          ]
        },
        :veggies => { :green => { :spinach => true } }
      })

      subject.interpolate(dataset)
      expect(subject.xml_fragment).to be_equivalent_to xml_fragment('output/merge_field_set/merge_field_set')
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
      }.to raise_error(Sheng::Sequence::MissingEndTag, "no end tag for sequence: library.books")
    end

    it 'throws exception if sequence nesting is wrong' do
      subject = described_class.new('key', xml_fragment('input/sequence/bad/badly_nested_sequence'))
      expect {
        subject.to_tree
      }.to raise_error(Sheng::Sequence::ImproperNesting, "expected end:birds, got end:animals")
    end
  end

  describe '#required_hash' do
    it 'returns skeleton hash demonstrating required data for interpolation' do
      expect(subject.required_hash).to eq({
        "person" => { "first_name" => nil, "last_name" => nil, "socks" => [{"color"=>nil, "size"=>nil}] },
        "veggies"=> { "green" => { "spinach" => nil } }
      })
    end

    it 'uses given value as placeholder for mergefields/checkboxes' do
      expect(subject.required_hash(:foo)).to eq({
        "person" => { "first_name" => :foo, "last_name" => :foo, "socks" => [{"color"=>:foo, "size"=>:foo}] },
        "veggies"=> { "green" => { "spinach" => :foo } }
      })
    end
  end
end
