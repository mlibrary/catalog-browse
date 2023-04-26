describe SubjectItem do
  context ".for" do
    it "returns with a Cross Reference if the doc has a see_also" do
      cross_reference_doc = {"see_also" => ["some subject || 9"]}
      item = described_class.for(browse_doc: cross_reference_doc, exact_match: false)
      expect(item.class).to eq(SubjectItemWithCrossReferences)
    end
    it "returns a regular subject item if it's any other record type" do
      doc = {} # doesn't even have a record_type
      item = described_class.for(browse_doc: doc, exact_match: false)
      expect(item.class).to eq(SubjectItem)
    end
  end
  context "subject" do
    before(:each) do
      @params = {
        browse_doc: JSON.parse(fixture("subject_results.json"))["response"]["docs"].first,
        exact_match: false
      }
    end
    subject do
      described_class.new(**@params)
    end
    it "returns the term field" do
      expect(subject.subject).to eq("Civil war")
    end
    it "doesn't have cross references" do
      expect(subject.has_cross_references?).to eq(false)
    end
    it "returns the expected url" do
      expect(subject.url).to include("query=#{URI.encode_www_form_component("subject_browse_leftanchored:(\"Civil war\")")}&filter.search_only=false")
    end
  end
end
describe SubjectItemWithCrossReferences do
  before(:each) do
    @items = JSON.parse(fixture("subject_results.json"))["response"]["docs"]
  end
  context "#has_cross_references?" do
    before(:each) do
      @params = {
        browse_doc: @items.first,
        exact_match: false
      }
    end
    subject do
      described_class.new(**@params)
    end
    it "is true" do
      expect(subject.has_cross_references?).to eq(true)
    end
  end
  context "#cross_references.broader" do
    before(:each) do
      @params = {
        browse_doc: @items.first,
        exact_match: false
      }
    end
    subject do
      described_class.new(**@params)
    end
    let :broader do
      subject.cross_references.broader
    end
    it "has at least one cross reference of 'broader'" do
      expect(broader).not_to be_nil
    end
    it "has a false 'heading_link?'" do
      expect(broader.first.heading_link?).to eq(false)
    end
    it "has a subject_display" do
      expect(broader.first.subject_display).to eq("Government, Resistance to (in subject list)")
    end
    it "has a count" do
      expect(broader.first.count).to eq("616")
    end
    it "displays records" do
      expect(broader.first.record_text).to eq("616 records")
    end
    it "has a url that's a subject query" do
      expect(subject.cross_references.broader.first.url).to include("subject?query=")
    end
  end
  context "#cross_references.narrower" do
    before(:each) do
      @params = {
        browse_doc: @items.first,
        exact_match: false
      }
    end
    subject do
      described_class.new(**@params)
    end
    let :narrower do
      subject.cross_references.narrower
    end
    it "has at least one cross reference of 'narrower'" do
      expect(narrower).not_to be_nil
    end
    it "has a false 'heading_link?'" do
      expect(narrower.first.heading_link?).to eq(false)
    end
    it "has a subject_display" do
      expect(narrower.first.subject_display).to eq("Insurgency (in subject list)")
    end
    it "has a count" do
      expect(narrower.first.count).to eq("199")
    end
    it "displays records" do
      expect(narrower.first.record_text).to eq("199 records")
    end
    it "has a url that's a subject query" do
      expect(subject.cross_references.narrower.first.url).to include("subject?query=")
    end
  end
  context "#cross_references.see_also" do
    before(:each) do
      @params = {
        browse_doc: @items[1],
        exact_match: false
      }
    end
    subject do
      described_class.new(**@params)
    end
    let :see_also do
      subject.cross_references.see_also
    end
    it "has at least one cross reference of 'see_also'" do
      expect(see_also).not_to be_nil
    end
    it "has a false 'heading_link?'" do
      expect(see_also.first.heading_link?).to eq(false)
    end
    it "has a subject_display" do
      expect(see_also.first.subject_display).to eq("Indigenous peoples (in subject list)")
    end
    it "has a count" do
      expect(see_also.first.count).to eq("441")
    end
    it "displays records" do
      expect(see_also.first.record_text).to eq("441 records")
    end
    it "has a url that's a subject query" do
      expect(subject.cross_references.see_also.first.url).to include("subject?query=")
    end
  end
end
