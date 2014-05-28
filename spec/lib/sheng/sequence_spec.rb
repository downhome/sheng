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
  end
end
