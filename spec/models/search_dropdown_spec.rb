require_relative "../spec_helper"
describe SearchDropdown, "#url" do
  before(:each) do
    @query = "Things"
    @type = "keyword"
  end
  def encoded_query(query)
    URI.encode_www_form_component(query)
  end
  subject do
    described_class.for(type: @type, query: @query).url
  end
  it "returns keyword url" do
    expect(subject).to eq("https://search.lib.umich.edu/catalog?query=#{encoded_query("keyword:(Things)")}")
  end
  it "returns appropriate browse url" do
    @type = "browse_by_callnumber"
    expect(subject).to eq("#{S.base_url}/callnumber?query=#{encoded_query("Things")}")
  end
  it "sends the user to search if they submit nonexistent browse_by type" do
    @type = "browse_by_something_that_does_not_exist"
    expect(subject).to eq("https://search.lib.umich.edu")
  end
end
