describe BrowseSolrClient do
  subject do
    described_class.new
  end
  context "#exact_matches" do
    it "returns an array of ids for an exact match" do
      stub_solr_get_request(url: "#{S.call_number_collection}/select", query: hash_including({fq: 'callnumber:"Thing"'}), output: fixture("biblio_results.json"))
      expect(subject.exact_matches(value: "Thing")).to eq(["990059013360106381", "990011613060106381", "990085202960106381", "990155473530106381", "990017586110106381"])
    end
    it "returns an empty errary if the solr request fails" do
      stub_solr_get_request(url: "#{S.call_number_collection}/select", query: hash_including({fq: 'callnumber:"Thing"'}), no_return: true).to_timeout
      expect(subject.exact_matches(value: "Thing")).to eq([])
    end
  end
end
