describe Sheng::MergeFieldSet do
  subject { described_class.new('key', xml_fragment('input/merge_field_set')) }

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
      expect(subject.xml_fragment).to be_equivalent_to xml_fragment('output/merge_field_set')
    end
  end
end
