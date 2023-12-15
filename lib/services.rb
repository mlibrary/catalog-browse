require "canister"

Services = Canister.new
S = Services

S.register(:solrcloud_on?) do
  ENV["SOLRCLOUD_ON"] == "true"
end

S.register(:call_number_collection) do
  S.solrcloud_on? ? ENV["CALL_NUMBER_COLLECTION"] : ENV["CALLNUMBER_CORE"]
end

S.register(:authority_collection) do
  S.solrcloud_on? ? ENV["AUTHORITY_COLLECTION"] : ENV["AUTHORITY_CORE"]
end

S.register(:solr_url) do
  S.solrcloud_on? ? ENV["SOLRCLOUD_URL"] : ENV["BROWSE_SOLR"]
end

[
  "BIBLIO_SOLR", "SOLR_USER", "SOLR_PASSWORD", "BASE_URL", "SEARCH_URL"
].each do |e|
  Services.register(e.downcase.to_sym) { ENV[e] }
end
