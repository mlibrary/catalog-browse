describe AuthorItem do
  context ".for" do
    it "returns with an Cross Reference if the doc has a see_also" do
      cross_reference_doc = {"see_also" => ["some author || 9"]}
      item = described_class.for(browse_doc: cross_reference_doc, exact_match: false)
      expect(item.class).to eq(AuthorItemWithCrossReferences)
    end
    it "returns a regular author item if it's any other record type" do
      doc = {} # doesn't even have a record_type
      item = described_class.for(browse_doc: doc, exact_match: false)
      expect(item.class).to eq(AuthorItem)
    end
  end
  context "author" do
    it "returns the term field" do
      params = {
        browse_doc: JSON.parse(fixture("author_results.json"))["response"]["docs"].first,
        exact_match: false
      }
      expect(described_class.new(**params).author).to eq("Twain, Mark")
    end
  end
end
describe AuthorItemWithCrossReferences do
  before(:each) do
    @params = {
      browse_doc: JSON.parse(fixture("author_redirect_doc.json")),
      exact_match: false
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#has_cross_references?" do
    it "is true" do
      expect(subject.has_cross_references?).to eq(true)
    end
  end
  context "#cross_references.first" do
    let :see_also do
      subject.cross_references.first
    end
    it "has a cross referencess of kind 'see_also'" do
      expect(see_also.kind).to eq("see_also")
    end
    it "has a false 'heading_link?'" do
      expect(see_also.heading_link?).to eq(false)
    end
    it "has an author_display" do
      expect(see_also.author_display).to eq("Clemens, Samuel Langhorne, 1835-1910 (in author list)")
    end
    it "has a count" do
      expect(see_also.count).to eq("7")
    end
    it "has a url that's an author query" do
      expect(subject.cross_references.first.url).to include("author?query=")
    end
  end
end
