describe Sheng::DataSet do
  describe '#new' do
    it 'raises an argument error if not given a Hash' do
      not_a_hash = double('Not a Hash')
      allow(not_a_hash).to receive(:is_a?).with(Hash).and_return(false)
      expect {
        described_class.new(not_a_hash)
      }.to raise_error(ArgumentError, "must be initialized with a Hash")
    end

    it 'deep symbolizes the given hash and assigns it to #raw_hash' do
      a_hash = double(Hash, :deep_symbolize_keys => :an_awesome_symbolized_hash)
      allow(a_hash).to receive(:is_a?).with(Hash).and_return(true)
      subject = described_class.new(a_hash)
      expect(subject.raw_hash).to eq :an_awesome_symbolized_hash
    end
  end

  describe '#fetch' do
    let(:raw_hash) {
      {
        :rabbits => {
          :streamlined => [:super_rabbit, :dr_slinky],
          :slow => :mr_molasses
        }
      }
    }
    subject { described_class.new(raw_hash) }

    it 'returns a non-hash object found at key' do
      expect(subject.fetch('rabbits.slow')).to eq :mr_molasses
      expect(subject.fetch('rabbits.streamlined')).to eq [:super_rabbit, :dr_slinky]
    end

    it 'raises an error if not given a string' do
      not_a_string = double('Not a String')
      allow(not_a_string).to receive(:is_a?).with(String).and_return(false)
      expect {
        subject.fetch(not_a_string)
      }.to raise_error(ArgumentError, "must provide a string")
    end

    it 'raises a KeyNotFound error if key not found' do
      expect {
        subject.fetch('rabbits.funky')
      }.to raise_error(described_class::KeyNotFound, "did not find in dataset: rabbits.funky (funky not found)")
    end

    it 'does not raise error on key not found if default given' do
      expect(subject.fetch('rabbits.funky', :default => "horse")).to eq("horse")
    end

    it 'raises an error if Hash found at key' do
      expect {
        subject.fetch('rabbits')
      }.to raise_error(described_class::KeyNotFound, "result at rabbits is a Hash")
    end

    it 'raises an error if key is too long' do
      expect {
        subject.fetch('rabbits.slow.but_steady')
      }.to raise_error(described_class::KeyNotFound, "in rabbits.slow.but_steady, slow did not return a Hash")
    end
  end
end