require "canister"

Services = Canister.new
S = Services

S.register(:solrcloud_on?) do
  ENV["SOLRCLOUD_ON"] == "true"
end

S.register(:authority_collection) do
  S.solrcloud_on? ? ENV["AUTHORITY_COLLECTION"] : ENV["AUTHORITY_CORE"]
end

S.register(:solrcloud_url) do
  S.solrcloud_on? ? ENV["SOLRCLOUD_URL"] : ENV["BROWSE_SOLR"]
end

[
  "BROWSE_SOLR", "BIBLIO_SOLR", "SOLR_USER", "SOLR_PASSWORD",
  "CALLNUMBER_CORE", "AUTHORITY_CORE"
].each do |e|
  Services.register(e.downcase.to_sym) { ENV[e] }
end
