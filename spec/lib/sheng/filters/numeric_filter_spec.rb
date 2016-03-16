require "shared_examples/filters"

describe Sheng::Filters::NumericFilter do
  test_cases = [
    { method: :round, arguments: [2], input: 149.3783, output: 149.38 },
    { method: :floor, input: 149.3783, output: 149 }
  ]

  it_behaves_like "a filter", test_cases

  context "with value that does not respond to method" do
    describe "#filter" do
      it "returns unmodified value" do
        subject = described_class.new(method: :round)
        expect(subject.filter("apples")).to eq("apples")
      end
    end
  end
end