describe Sheng::Sequence do
  let(:fragment) { xml_fragment('input/sequence/sequence') }
  let(:element) { fragment.xpath("//w:fldSimple[contains(@w:instr, 'start:')]").first }
  let(:merge_field) { Sheng::MergeField.new(element) }
  subject { described_class.new(merge_field) }

  describe "#raw_key" do
    it "returns key from start_field" do
      expect(subject.raw_key).to eq(merge_field.raw_key)
    end
  end

  describe '#interpolate' do
    context "with an array of objects" do
      it 'duplicates template and replaces mergefields for each array member' do
        dataset = Sheng::DataSet.new({
          :library => {
            :books => [
              { :title => 'A Radish Summer', :scent => 'totally rad' },
              { :title => 'Elephants Are Not Your Friend', :scent => 'stinky' }
            ]
          }
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/sequence')
      end

      it 'does nothing if key not found in dataset' do
        dataset = Sheng::DataSet.new({})

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to fragment
      end
    end

    context "with an array of primitives" do
      context "with default iteration variable" do
        let(:fragment) { xml_fragment('input/sequence/array_sequence') }

        it "substitutes default variable with array elements" do
          dataset = Sheng::DataSet.new({
            :my_dog => {
              :favorite_toys => ["rooster", "wallet", "foot"]
            }
          })

          subject.interpolate(dataset)
          expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/array_sequence')
        end
      end

      context "with overridden iteration variable" do
        let(:fragment) { xml_fragment('input/sequence/overridden_iterator_array_sequence') }

        it "substitutes given variable" do
          dataset = Sheng::DataSet.new({
            :perps => ["Hamburglar", "Tony the Tiger"]
          })

          subject.interpolate(dataset)
          expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/overridden_iterator_array_sequence')
        end
      end
    end

    context "with an inline sequence" do
      let(:fragment) { xml_fragment('input/sequence/inline_sequence') }

      it "interpolates and maintains inline structure" do
        dataset = Sheng::DataSet.new({
          :library => {
            :books => [
              { :title => 'A Radish Summer', :scent => 'totally rad' },
              { :title => 'Elephants Are Not Your Friend', :scent => 'stinky' }
            ]
          }
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/inline_sequence')
      end
    end

    context "with a requested comma-separated series" do
      let(:fragment) { xml_fragment('input/sequence/series_with_commas') }
      let(:element) { fragment.xpath("//w:instrText").first }

      it "creates a comma-separated list with commas (including serial comma and conjunction)" do
        dataset = Sheng::DataSet.new({
          :buffoons => [
            { :first_name => "Snookers", :last_name => "Fumpleton" },
            { :first_name => "Francis", :last_name => "Oldgark" },
            { :first_name => "Spanky", :last_name => "McThanks" }
          ]
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/series_with_commas')
      end

      context "with custom conjunction" do
        let(:fragment) { xml_fragment('input/sequence/series_with_commas', :gsub => { "series_with_commas" => "series_with_commas(und)"}) }

        it "uses given conjunction instead of default 'and'" do
          dataset = Sheng::DataSet.new({
            :buffoons => [
              { :first_name => "Snookers", :last_name => "Fumpleton" },
              { :first_name => "Francis", :last_name => "Oldgark" },
              { :first_name => "Spanky", :last_name => "McThanks" }
            ]
          })

          subject.interpolate(dataset)
          expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/series_with_commas', :gsub => { ", and" => ", und"})
        end
      end
    end

    context "with table-based sequences" do
      let(:fragment) { xml_fragment('input/sequence/sequence_in_table') }

      it "creates new rows for each collection object" do
        dataset = Sheng::DataSet.new({
          :meals => [
            { :meal => 'Gravel Noodles', :appetizer => 'Asphalt Rollups', :dessert => 'Concrete Cream', :drink => 'Steamed Water' },
            { :meal => 'A Single Olive', :appetizer => 'A Strand of Hair', :dessert => 'Wishes and Hopes', :drink => 'The Memory of Soda' }
          ]
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/sequence_in_table')
      end
    end

    context "with embedded sequences" do
      let(:fragment) { xml_fragment('input/sequence/embedded_sequence') }

      it "iterates over sub-sequences properly" do
        dataset = Sheng::DataSet.new({
          :library => {
            :books => [
              { :title => 'A Radish Summer', :scent => 'totally rad', :pages => [{ :size => 'huge'}, { :size => 'tiny'}] },
              { :title => 'Elephants Are Not Your Friend', :scent => 'stinky', :pages => [{ :size => 'gigantic'}] }
            ]
          }
        })

        subject.interpolate(dataset)
        expect(subject.xml_document).to be_equivalent_to xml_fragment('output/sequence/embedded_sequence')
      end
    end
  end

  describe '#new' do
    context "with unclosed sequence" do
      let(:fragment) { xml_fragment('input/sequence/bad/unclosed_sequence') }
      it 'raises an exception indicating the missing end tag' do
        dataset = Sheng::DataSet.new({})
        expect {
          subject
        }.to raise_error(described_class::MissingEndTag, "no end tag for start:library.books")
      end
    end

    context "with badly nested sequence" do
      let(:fragment) { xml_fragment('input/sequence/bad/badly_nested_sequence') }
      it 'raises an exception indicating the nesting issue' do
        dataset = Sheng::DataSet.new({})
        expect {
          subject
        }.to raise_error(described_class::ImproperNesting, "expected end tag for start:birds, got end:animals")
      end
    end
  end
end
