describe StringCleaner do
  context ".strip_symbols" do
    it "removes certain punctuation" do
      expect(described_class.strip_symbols('"\'')).to eq("")
    end
  end
  context ".cleanup_browse_string" do
    it "removes 'author:' prefix" do
      expect(described_class.clean_browse_string('author:"Author Name"')).to eq("Author Name")
    end
    it "removes 'isn(' prefix" do
      expect(described_class.clean_browse_string("isn:(123-456)")).to eq("(123-456)")
    end
  end
end
