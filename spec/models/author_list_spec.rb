describe AuthorList do
  before(:each) do
    @browse_list = instance_double(BrowseList, original_reference: "author")
  end
  subject do
    described_class.new(browse_list: @browse_list)
  end

  context "doc_title" do
    it "returns the document title" do
      expect(subject.doc_title).to eq("Browse by Author")
    end
  end

  context "match_text" do
    it "returns appropriate text for no matches" do
      allow(@browse_list).to receive(:num_matches).and_return(0)
      expect(subject.match_text).to include("no exact match")
    end
    it "returns appropriate text for 1 match" do
      allow(@browse_list).to receive(:num_matches).and_return(1)
      expect(subject.match_text).to include("a matching author")
    end
    it "returns appropriate text for 2 matches" do
      allow(@browse_list).to receive(:num_matches).and_return(2)
      expect(subject.match_text).to include("We found 2 matching items")
    end
  end
  context "#previous_url" do
    it "returns appropriate url" do
      allow(@browse_list).to receive(:previous_url_params).and_return({param_1: "value_1", param_2: "value_2"})
      expect(subject.previous_url).to eq("#{S.base_url}/author?param_1=value_1&param_2=value_2")
    end
  end
  context "#next_url" do
    it "returns appropriate url" do
      allow(@browse_list).to receive(:next_url_params).and_return({param_1: "value_1", param_2: "value_2"})
      expect(subject.next_url).to eq("#{S.base_url}/author?param_1=value_1&param_2=value_2")
    end
  end
end
describe AuthorList::Error do
  before(:each) do
    @params = {
      original_reference: "OSU"
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#error?" do
    it "returns true" do
      expect(subject.error?).to eq(true)
    end
  end
  context "#error_message" do
    it "returns an error message" do
      expect(subject.error_message).to eq("<span class=\"strong\">{:original_reference=>\"OSU\"}</span> is not a valid author query.")
    end
  end
end
