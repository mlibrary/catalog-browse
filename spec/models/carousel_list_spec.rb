describe CarouselList do
  before(:each) do
    @browse_client = instance_double(BrowseSolrClient)
    @catalog_client = instance_double(CatalogSolrClient::Client, get_bibs: OpenStruct.new(body: JSON.parse(fixture("biblio_results.json"))))
  end
  subject do
    described_class.list("my_call_number", @browse_client, @catalog_client)
  end
  def body(file_name)
    out = JSON.parse(fixture(file_name))
    OpenStruct.new(body: out)
  end
  it "returns a list of carousel items" do
    allow(@browse_client).to receive(:browse_reference_on_bottom).and_return(body("callnumbers_before.json"))

    allow(@browse_client).to receive(:browse_reference_on_top).and_return(body("callnumbers_results.json"))
    expect(subject.first[:call_number]).to eq("Z 253 .U581 1952")
  end
end
describe CarouselList::CarouselItem do
  before(:each) do
    @catalog_doc = JSON.parse(fixture("biblio_results.json"))["response"]["docs"].first
    @browse_doc = JSON.parse(fixture("callnumbers_results.json"))["response"]["docs"].first
  end
  subject do
    described_class.new(@catalog_doc, @browse_doc)
  end
  it "has a title" do
    expect(subject.title).to eq("Theory and practice of composition.")
  end
  it "has an author" do
    expect(subject.author).to eq("United States. Government Printing Office")
  end
  it "has a call_number" do
    expect(subject.call_number).to eq("Z 253 .U6 1963")
  end
  it "has an isbn" do
    expect(subject.isbn).to eq(nil)
  end
  it "has an issn" do
    expect(subject.issn).to eq(nil)
  end
  it "has an oclc" do
    expect(subject.oclc).to eq("2497305")
  end
  it "has an mms_id" do
    expect(subject.mms_id).to eq("990011613060106381")
  end
  it "has a date" do
    expect(subject.date).to eq("1950")
  end
  it "has a url" do
    expect(subject.url).to eq("#{S.search_url}/catalog/record/990011613060106381")
  end
  it "has a hash output" do
    expect(subject.to_h).to eq(
      {
        author: "United States. Government Printing Office",
        call_number: "Z 253 .U6 1963",
        date: "1950",
        isbn: nil,
        issn: nil,
        oclc: "2497305",
        title: "Theory and practice of composition.",
        url: "#{S.search_url}/catalog/record/990011613060106381"

      }
    )
  end
end
