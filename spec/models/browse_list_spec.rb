require_relative "../spec_helper"
describe BrowseList do
  context ".for" do
    before(:each) do
      @browse_client = instance_double(BrowseSolrClient, exact_matches: [])
      @params = {
        direction: nil,
        reference_id: nil,
        num_rows_to_display: 20,
        original_reference: nil,
        banner_reference: nil,
        browse_solr_client: @browse_client,
        match_field: "my_match_field"
      }
    end
    subject do
      described_class.for(**@params)
    end
    it "returns a ReferenceOnTop when direction is next" do
      @params[:direction] = "next"
      allow(@browse_client).to receive(:browse_reference_on_top)
      expect(subject.class).to eq(BrowseList::ReferenceOnTop)
      expect(@browse_client).to have_received(:browse_reference_on_top).with(
        {reference_id: nil, rows: 22}
      )
    end
    it "returns a ReferenceOnTop when direction is previous" do
      @params[:direction] = "previous"
      allow(@browse_client).to receive(:browse_reference_on_bottom)
      expect(subject.class).to eq(BrowseList::ReferenceOnBottom)
      expect(@browse_client).to have_received(:browse_reference_on_bottom).with(
        {reference_id: nil, rows: 21}
      )
    end
    context "direction is nil" do
      it "returns a ReferenceInMiddle if there's a reference_id" do
        @params[:reference_id] = "Something"
        allow(@browse_client).to receive(:browse_reference_on_top)
        allow(@browse_client).to receive(:browse_reference_on_bottom)
        expect(subject.class).to eq(BrowseList::ReferenceInMiddle)
        expect(@browse_client).to have_received(:browse_reference_on_top).with({field: "my_match_field", reference_id: "Something", rows: 19})
        expect(@browse_client).to have_received(:browse_reference_on_bottom).with({field: "my_match_field", reference_id: "Something", rows: 3})
      end
      it "returns a Empty if there in not a reference_id" do
        expect(subject.class).to eq(BrowseList::Empty)
      end
    end
  end
end
describe BrowseList::ReferenceOnTop do
  before(:each) do
    # rows would be 3.
    @params = {
      index_response: JSON.parse(fixture("callnumbers_results.json")),
      num_rows_to_display: 3,
      original_reference: "Z 253 .U6 1963",
      exact_matches: [],
      banner_reference: "banner_reference"
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#next_reference_id" do
    it "for edgeless list, returns next to last ref id" do
      expect(subject.next_reference_id).to eq("Z 253 .U69 2017 ||990155473530106381")
    end
    it "for edged list, returns nil" do
      @params[:num_rows_to_display] = 4
      expect(subject.next_reference_id).to be_nil
    end
  end
  context "#previous_reference_id" do
    it "returns the second item in the list" do
      expect(subject.previous_reference_id).to eq("Z 253 .U63 1971||990017586110106381")
    end
  end
  context "#has_previous_list?" do
    it "returns true" do
      expect(subject.has_previous_list?).to eq(true)
    end
  end
  context "#previous_url_params" do
    it "returns appropriate url" do
      expect(subject.previous_url_params).to eq({
        query: @params[:original_reference],
        direction: "previous",
        reference_id: "Z 253 .U63 1971||990017586110106381",
        banner_reference: "banner_reference"
      })
    end
  end
  context "#next_url_parms" do
    it "returns appropriate url" do
      expect(subject.next_url_params).to eq({
        query: @params[:original_reference],
        direction: "next",
        reference_id: "Z 253 .U69 2017 ||990155473530106381",
        banner_reference: "banner_reference"
      })
    end
  end
  context "#docs" do
    it "returns an Array of browse docs with the correct number of rows and the correct first and last item" do
      docs = subject.docs
      expect(docs.count).to eq(3)
      expect(docs.first["callnumber"].strip).to eq("Z 253 .U63 1971")
      expect(docs.last["callnumber"].strip).to eq("Z 253 .U69 2017")
    end
  end
end
describe BrowseList::ReferenceOnBottom do
  before(:each) do
    @params = {
      index_response: JSON.parse(fixture("callnumbers_results.json")),
      # has 5 results
      num_rows_to_display: 4,
      original_reference: "Z 253 .U6 1963",
      exact_matches: [],
      banner_reference: ""
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#has_next_list?" do
    it "returns true" do
      expect(subject.has_next_list?).to eq(true)
    end
  end
  context "#has_previous_list?" do
    it "is true when the number of documents returned is equal to number of display rows + 1" do
      expect(subject.has_previous_list?).to eq(true)
    end
    it "is false when the number of documents returned is not equal to display rows + 1" do
      @params[:num_rows_to_display] = 5
      expect(subject.has_previous_list?).to eq(false)
    end
  end
  context "#next_reference_id" do
    it "before resort; returns first item in index list." do
      expect(subject.next_reference_id).to eq("Z 253 .U6 1963||990011613060106381")
    end
  end
  context "#previous_reference_id" do
    it "when it has previous_reference_id and before the resort; it returns the second to last item in the index list" do
      expect(subject.previous_reference_id).to eq("Z 253 .U69 2017 ||990155473530106381")
    end
    it "returns nil when there's no previous list" do
      @params[:num_rows_to_display] = 5
      expect(subject.previous_reference_id).to be_nil
    end
  end
end
describe BrowseList::ReferenceInMiddle do
  before(:each) do
    @params = {
      index_before: JSON.parse(fixture("callnumbers_before.json")),
      index_after: JSON.parse(fixture("callnumbers_results.json")),
      num_rows_to_display: 6,
      original_reference: "Z 253 .U6 1963",
      exact_matches: [],
      banner_reference: ""
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#docs" do
    it "returns starting ending doc from separate solr calls" do
      docs = subject.docs
      expect(docs.count).to eq(6)
      expect(docs.first["callnumber"].strip).to eq("Z 253 .U581")
      expect(docs.last["callnumber"].strip).to eq("Z 253 .U69 2017")
    end
  end
end
describe BrowseList::Empty do
  before(:each) do
    @params = {
      original_reference: ""
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#show_table?" do
    it "returns false" do
      expect(subject.show_table?).to eq(false)
    end
  end
end
