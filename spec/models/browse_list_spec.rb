require_relative '../spec_helper.rb'
describe BrowseList::ReferenceAtTop do
  before(:each) do
    #rows would be 3.
    @params = {
      index_response: JSON.parse(fixture('callnumbers_results.json')),
      biblio_response: JSON.parse(fixture('biblio_results.json')),
      num_rows_to_display: 3 
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#next_reference_id" do
    it "for edgeless list, returns next to last ref id" do
      expect(subject.next_reference_id).to eq('Z 253 .U69 2017')
    end
    it "for edged list, returns nil" do
      @params[:num_rows_to_display] = 4
      expect(subject.next_reference_id).to be_nil
    end
  end
  context "#previous_reference_id" do
    it "returns the second item in the list" do
      expect(subject.previous_reference_id).to eq('Z 253 .U63 1971')
    end
  end
end

