describe Sheng::Sequence do
  describe '#interpolate' do
    it 'duplicates template and replaces mergefields for each array member' do
      dataset = Sheng::DataSet.new({
        :library => {
          :books => [
            { :title => 'A Radish Summer', :scent => 'totally rad' },
            { :title => 'Elephants Are Not Your Friend', :scent => 'stinky' }
          ]
        }
      })

      xml = xml_fragment('input/sequence')
      merge_field = Sheng::MergeField.new(xml.xpath("//w:fldSimple[contains(@w:instr, 'start:')]").first)
      subject = described_class.new(merge_field)
      subject.interpolate(dataset)
      expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence')
    end

    it 'can handle table-based sequences with multiple rows' do
      dataset = Sheng::DataSet.new({
        :meals => [
          { :meal => 'Gravel Noodles', :appetizer => 'Asphalt Rollups', :dessert => 'Concrete Cream', :drink => 'Steamed Water' },
          { :meal => 'A Single Olive', :appetizer => 'A Strand of Hair', :dessert => 'Wishes and Hopes', :drink => 'The Memory of Soda' }
        ]
      })

      xml = xml_fragment('input/table')
      merge_field = Sheng::MergeField.new(xml.xpath("//w:fldSimple[contains(@w:instr, 'start:')]").first)
      subject = described_class.new(merge_field)
      subject.interpolate(dataset)
      expect(subject.xml_document).to be_equivalent_to xml_fragment('output/table')
    end

    it 'can handle embedded sequences' do
      dataset = Sheng::DataSet.new({
        :library => {
          :books => [
            { :title => 'A Radish Summer', :scent => 'totally rad', :pages => [{ :size => 'huge'}, { :size => 'tiny'}] },
            { :title => 'Elephants Are Not Your Friend', :scent => 'stinky', :pages => [{ :size => 'gigantic'}] }
          ]
        }
      })

      xml = xml_fragment('input/embedded_sequence')
      merge_field = Sheng::MergeField.new(xml.xpath("//w:fldSimple[contains(@w:instr, 'start:')]").first)
      subject = described_class.new(merge_field)

      subject.interpolate(dataset)
      expect(subject.xml_document).to be_equivalent_to xml_fragment('output/embedded_sequence')
    end
  end

  describe '#new' do
    it 'raises an exception if sequence has no end tag' do
      dataset = Sheng::DataSet.new({})

      xml = xml_fragment('input/bad_sequences/no_end')
      merge_field = Sheng::MergeField.new(xml.xpath("//w:fldSimple[contains(@w:instr, 'start:')]").first)
      expect {
        subject = described_class.new(merge_field)
      }.to raise_error(described_class::MissingEndTag, "no end tag for sequence: library.books")
    end
  end
end
