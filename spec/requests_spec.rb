require "spec_helper"
describe "requests" do
  include Rack::Test::Methods
  before(:each) do
    @call_number_collection = S.call_number_collection
    @authority_collection = S.authority_collection
    @authority_match_field = "id"
  end
  context "get /" do
    it "has status OK" do
      get "/"
      expect(last_response.status).to eq(200)
    end
  end
  context "get /callnumber" do
    it "for a successful query, returns status OK" do
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({fq: 'callnumber:"Thing"'}), output: fixture("biblio_results.json"))
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({sort: "callnumber desc"}), output: fixture("callnumbers_before.json"))
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({fq: 'callnumber:["Thing" TO *]'}), output: fixture("callnumbers_results.json"))
      stub_biblio_get_request(url: "biblio/select", query: hash_including({}), output: fixture("biblio_results_middle.json"))
      get "/callnumber", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
    it "for a network error, it still returns a successful response, but with an error message" do
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({fq: 'callnumber:"Thing"'}), no_return: true).to_timeout
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({sort: "callnumber desc"}), no_return: true).to_timeout
      get "/callnumber", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
  end
  context "get /author" do
    it "returns status OK" do
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({fq: "term:\"Thing\""}), output: fixture("author_exact_matches.json"))
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({sort: "#{@authority_match_field} desc"}), output: fixture("author_results.json"))
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({fq: "#{@authority_match_field}:[\"Thing\" TO *]"}), output: fixture("author_results.json"))
      get "/author", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
    it "for a network error, it still returns a successful response, but with an error message" do
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({fq: "term:\"Thing\""}), no_return: true).to_timeout
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({sort: "#{@authority_match_field} desc"}), no_return: true).to_timeout
      get "/author", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
  end
  context "get /subject" do
    it "returns status OK" do
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({fq: "term:\"Thing\""}), output: fixture("author_exact_matches.json"))
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({sort: "#{@authority_match_field} desc"}), output: fixture("subject_results.json"))
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({fq: "#{@authority_match_field}:[\"Thing\" TO *]"}), output: fixture("subject_results.json"))
      get "/subject", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
    it "for a network error, it still returns a successful response, but with an error message" do
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({fq: "term:\"Thing\""}), no_return: true).to_timeout
      stub_solr_get_request(url: "#{@authority_collection}/select", query: hash_including({sort: "#{@authority_match_field} desc"}), no_return: true).to_timeout
      get "/subject", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
  end
  context "post /search" do
    it "redirects to appropriate url for given parameters" do
      post "/search", {type: "browse_by_author", query: "Thing"}
      expect(last_response.status).to eq(302)
      expect(last_response.headers["Location"]).to eq("#{S.base_url}/author?query=Thing")
    end
  end
  context "get /carousel" do
    it "returns some json" do
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({fq: 'callnumber:"Thing"'}), output: fixture("biblio_results.json"))
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({sort: "callnumber desc"}), output: fixture("callnumbers_before.json"))
      stub_solr_get_request(url: "#{@call_number_collection}/select", query: hash_including({fq: 'callnumber:["Thing" TO *]'}), output: fixture("callnumbers_results.json"))
      stub_biblio_get_request(url: "biblio/select", query: hash_including({}), output: fixture("biblio_results_middle.json"))
      get "/carousel", {query: "Thing"}
      expect(last_response.status).to eq(200)
    end
  end
  context "get /-/live" do
    it "returns status OK" do
      get "/-/live"
      expect(last_response.status).to eq(200)
    end
  end
end
