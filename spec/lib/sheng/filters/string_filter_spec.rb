require "shared_examples/filters"

describe Sheng::Filters::StringFilter do
  test_cases = [
    { method: :upcase, input: "some Good thing", output: "SOME GOOD THING" },
    { method: :downcase, input: "Emerald CITY", output: "emerald city" },
    { method: :reverse, input: "A Man a Plan", output: "nalP a naM A" },
    { method: :capitalize, input: "good will hunting", output: "Good will hunting" },
    { method: :titleize, input: "good will hunting", output: "Good Will Hunting" }
  ]

  it_behaves_like "a filter", test_cases

  context "with value that does not respond to method" do
    describe "#filter" do
      it "returns unmodified value" do
        subject = described_class.new(method: :upcase)
        expect(subject.filter(12345)).to eq(12345)
      end
    end
  end
end