describe AuthorItem, ".#for" do
  it "returns with an Cross Reference if the doc is of type redirect" do
    cross_reference_doc = {"record_type" => "redirect"}
    item = described_class.for(browse_doc: cross_reference_doc, exact_match: false)
    expect(item.class).to eq(AuthorItemWithCrossReferences)
  end
  it "returns a regular author item if it's any other record type" do
    doc = {} # doesn't even have a record_type
    item = described_class.for(browse_doc: doc, exact_match: false)
    expect(item.class).to eq(AuthorItem)
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
    it "has a cross referencess of kind 'see_also'" do
      expect(subject.cross_references.first.kind).to eq("see_also")
    end
    it "has a false 'heading_link?'" do
      expect(subject.cross_references.first.heading_link?).to eq(false)
    end
    it "has a url that's an author query" do
      expect(subject.cross_references.first.url).to include("author?query=")
    end
  end
end
