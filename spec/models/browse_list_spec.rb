require_relative '../spec_helper.rb'
describe BrowseList::ReferenceOnTop do
  before(:each) do
    #rows would be 3.
    @params = {
      index_response: JSON.parse(fixture('callnumbers_results.json')),
      catalog_response: JSON.parse(fixture('biblio_results.json')),
      num_rows_to_display: 3,
      original_reference: 'Z 253 .U6 1963',
      exact_matches: []
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "match_text" do
    it "returns appropriate text for no matches" do
      @params[:exact_matches] = [] 
      expect(subject.match_text).to include("no exact match")
    end
    it "returns appropriate text for 1 match" do
      @params[:exact_matches] = ['match_id1'] 
      expect(subject.match_text).to include("a matching call number")
    end
    it "returns appropriate text for 20 matches" do
      @params[:exact_matches] = ['match_id1', 'match_id2'] 
      expect(subject.match_text).to include("We found 2 matching items")
    end
  end
  context "#next_reference_id" do
    it "for edgeless list, returns next to last ref id" do
      expect(subject.next_reference_id).to eq('Z 253 .U69 2017 ||990155473530106381')
    end
    it "for edged list, returns nil" do
      @params[:num_rows_to_display] = 4
      expect(subject.next_reference_id).to be_nil
    end
  end
  context "#previous_reference_id" do
    it "returns the second item in the list" do
      expect(subject.previous_reference_id).to eq('Z 253 .U63 1971||990017586110106381')
    end
  end
  context "#has_previous_list?" do
    it "returns true" do
      expect(subject.has_previous_list?).to eq(true)
    end
  end
  context "#previous_url" do
    it "returns appropriate url" do
      prev_ref = URI.encode_www_form_component("Z 253 .U63 1971||990017586110106381")
      expect(subject.previous_url).to eq("/callnumber?query=#{URI.encode_www_form_component(@params[:original_reference])}&direction=previous&reference_id=#{prev_ref}")
    end
  end
  context "#next_url" do
    it "returns appropriate url" do
      next_ref = URI.encode_www_form_component('Z 253 .U69 2017 ||990155473530106381')
      expect(subject.next_url).to eq("/callnumber?query=#{URI.encode_www_form_component(@params[:original_reference])}&direction=next&reference_id=#{next_ref}")
    end
  end
  context "#items" do
    it "returns an Array of Browse Items with the correct number of rows and the correct first and last item" do
      items = subject.items
      expect(items.first.class.to_s).to include("BrowseItem")
      expect(items.count).to eq(3)
      expect(items.first.callnumber).to eq("Z 253 .U63 1971")
      expect(items.last.callnumber).to eq("Z 253 .U69 2017")
    end
  end
end
describe BrowseList::ReferenceOnBottom do
  before(:each) do
    @params = {
      index_response: JSON.parse(fixture('callnumbers_results.json')),
      #has 5 results
      catalog_response: JSON.parse(fixture('biblio_results.json')),
      num_rows_to_display: 4,
      original_reference: 'Z 253 .U6 1963',
      exact_matches: []
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
      index_before: JSON.parse(fixture('callnumbers_before.json')),
      index_after: JSON.parse(fixture('callnumbers_results.json')),
      catalog_response: JSON.parse(fixture('biblio_results_middle.json')),
      num_rows_to_display: 6,
      original_reference: 'Z 253 .U6 1963',
      exact_matches: []
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#items" do
  end
end
