require "spec_helper"
describe "requests" do
  include Rack::Test::Methods
  before(:each) do
    @callnumbers_core = ENV.fetch("CALLNUMBERS_CORE")
  end
  context "get /" do
    it "has status OK" do
      get "/"
      expect(last_response.status).to eq(200)
    end
  end
  context "get /callnumber" do
    it "returns status OK" do
      stub_solr_get_request(url: "#{@callnumbers_core}/select", query: hash_including({fq: 'callnumber:"Thing"'}), output: fixture("biblio_results.json"))
      stub_solr_get_request(url: "#{@callnumbers_core}/select", query: hash_including({sort: "id desc"}), output: fixture("callnumbers_before.json"))
      stub_solr_get_request(url: "#{@callnumbers_core}/select", query: hash_including({fq: 'id:["Thing" TO *]'}), output: fixture("callnumbers_results.json"))
      stub_biblio_get_request(url: "biblio/select", query: hash_including({}), output: fixture("biblio_results_middle.json"))
      get "/callnumber", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
  end
end
