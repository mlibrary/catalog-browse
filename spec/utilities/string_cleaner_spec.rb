describe StringCleaner do
  context ".strip_symbols" do
    it "removes punctuation" do
      # for \p{P}
      expect(described_class.strip_symbols('!"#%&\'()*,_./:;=?@[]\\_{}')).to eq("")
    end
    it "removes math symbols" do
      # for \p{Sm}
      expect(described_class.strip_symbols("+<=>|~≤≥±≠÷×")).to eq("")
    end
    it "removes currency symbols" do
      # for \p{Sc}
      expect(described_class.strip_symbols("$¢¥£€¤")).to eq("")
    end
    it "removes other symbols" do
      # for \p{So}
      expect(described_class.strip_symbols("©༕®°")).to eq("")
    end
    it "removes a few modifiers" do
      expect(described_class.strip_symbols("`^")).to eq("")
    end
  end
  context ".cleanup_author_browse_string" do
    it "cleans up symbols" do
      expect(described_class.cleanup_author_browse_string("©+$.")).to eq("")
    end
    it "removes 'author:' prefix" do
      expect(described_class.cleanup_author_browse_string('author:"Author Name"')).to eq("Author Name")
    end
  end
end
