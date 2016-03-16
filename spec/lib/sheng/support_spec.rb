describe Sheng::Support do
  describe ".is_numeric?" do
    it "returns true if given integer" do
      expect(described_class.is_numeric?(123)).to be true
    end

    it "returns true if given float" do
      expect(described_class.is_numeric?(123.4)).to be true
    end

    it "returns true if given BigDecimal" do
      expect(described_class.is_numeric?(123.4.to_d)).to be true
    end

    it "returns true if given valid numeric string" do
      expect(described_class.is_numeric?("123.4")).to be true
    end

    it "returns false if given invalid numeric string" do
      expect(described_class.is_numeric?("0123.4")).to be false
    end

    it "returns true if given valid numeric string with appropriate commas" do
      expect(described_class.is_numeric?("1,234.5")).to be true
    end

    it "returns false if given valid numeric string with appropriate commas" do
      expect(described_class.is_numeric?("12,34.5")).to be false
    end

    it "returns false if given non-numeric string" do
      expect(described_class.is_numeric?("foobar")).to be false
    end
  end
end