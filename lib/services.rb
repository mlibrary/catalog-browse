require "canister"

Services = Canister.new
S = Services

S.register(:solr_cloud_on?) do
  ENV["SOLR_CLOUD_ON"] == "true"
end

S.register(:author_solr) do
  ENV["AUTHOR_SOLR"] || ENV["BROWSE_SOLR"]
end

S.register(:author_collection) do
  ENV["AUTHOR_COLLECTION"] || ENV["AUTHORITY_CORE"]
end

[
  "BROWSE_SOLR", "BIBLIO_SOLR", "SOLR_USER", "SOLR_PASSWORD",
  "CALLNUMBER_CORE", "AUTHORITY_CORE"
].each do |e|
  Services.register(e.downcase.to_sym) { ENV[e] }
end
