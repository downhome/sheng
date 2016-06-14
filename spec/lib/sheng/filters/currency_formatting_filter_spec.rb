require "shared_examples/filters"

describe Sheng::Filters::CurrencyFormattingFilter do
  test_cases = [
    { method: :currency, input: 3452341.826, output: "3,452,341.83" },
    { method: :currency, input: "1645.3", output: "1,645.30" },
    { method: :currency, input: 192.3, output: "192.30" },
    { method: :currency, arguments: ["¥"], input: "12351.184", output: "¥12,351.18" }
  ]

  it_behaves_like "a filter", test_cases

  context "with non-numeric value" do
    describe "#filter" do
      it "returns unmodified value" do
        subject = described_class.new(method: :currency)
        expect(subject.filter("apples")).to eq("apples")
      end
    end
  end
end
