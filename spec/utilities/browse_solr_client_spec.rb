describe BrowseSolrClient do
  subject do
    described_class.new
  end
  context "#browse_reference_on_top" do
    it "uses id as the default range and sort field" do
      s = stub_solr_get_request(url: "#{S.call_number_collection}/select", query: hash_including(
        {
          fq: 'id:["whatever" TO *]',
          sort: "id asc"
        }
      ))
      subject.browse_reference_on_top(reference_id: "whatever")
      expect(s).to have_been_requested
    end
    it "uses field value as the default range and sort field when given" do
      s = stub_solr_get_request(url: "#{S.call_number_collection}/select", query: hash_including(
        {
          fq: 'some_other_field:["whatever" TO *]',
          sort: "some_other_field asc"
        }
      ))
      subject.browse_reference_on_top(reference_id: "whatever", field: "some_other_field")
      expect(s).to have_been_requested
    end
  end
  context "#browse_reference_on_bottom" do
    it "uses id as the default range and sort field" do
      s = stub_solr_get_request(url: "#{S.call_number_collection}/select", query: hash_including(
        {
          fq: 'id:{* TO "whatever"}',
          sort: "id desc"
        }
      ))
      subject.browse_reference_on_bottom(reference_id: "whatever")
      expect(s).to have_been_requested
    end
    it "uses field value as the default range and sort field when given" do
      s = stub_solr_get_request(url: "#{S.call_number_collection}/select", query: hash_including(
        {
          fq: 'some_other_field:{* TO "whatever"}',
          sort: "some_other_field desc"
        }
      ))
      subject.browse_reference_on_bottom(reference_id: "whatever", field: "some_other_field")
      expect(s).to have_been_requested
    end
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
