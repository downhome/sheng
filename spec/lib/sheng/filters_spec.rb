describe Sheng::Filters do
  before(:each) do
    allow(described_class).to receive(:registry).
      and_return(bazinga: Sheng::Filters::Base)
  end

  describe ".filter_for" do
    it "returns a filter instance that supports the given string" do
      allow(Sheng::Filters::Base).to receive(:new).
        with(method: "bazinga", arguments: [12, "hats"]).
        and_return(:the_filter)
      expect(described_class.filter_for("bazinga(12, hats)")).
        to eq(:the_filter)
    end

    it "raises exception if filter class not found" do
      expect {
        described_class.filter_for("unregistered(12, hats)")
      }.to raise_error(Sheng::Filters::UnsupportedFilterError)
    end
  end
end