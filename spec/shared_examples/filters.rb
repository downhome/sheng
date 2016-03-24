RSpec.shared_examples_for "a filter" do |test_cases|
  test_cases.map { |tc| tc[:method] }.uniq.each do |method|
    it "registers self for #{method} method" do
      expect(Sheng::Filters.registry[method]).to eq(described_class)
    end
  end

  test_cases.each do |test_case|
    context "with #{test_case[:method]} method" do
      describe "#filter" do
        it "returns filtered output" do
          subject = described_class.new(method: test_case[:method], arguments: test_case[:arguments] || [])
          expect(subject.filter(test_case[:input])).to eq(test_case[:output])
        end
      end
    end
  end
end
