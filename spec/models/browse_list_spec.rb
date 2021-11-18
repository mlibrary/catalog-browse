require_relative '../spec_helper.rb'
describe BrowseList::ReferenceOnTop do
  before(:each) do
    #rows would be 3.
    @params = {
      index_response: JSON.parse(fixture('callnumbers_results.json')),
      catalog_response: JSON.parse(fixture('biblio_results.json')),
      num_rows_to_display: 3,
      original_reference: 'Z 253 .U6 1963' 
    }
  end
  subject do
    described_class.new(**@params)
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

