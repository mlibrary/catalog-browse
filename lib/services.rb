require "canister"
require "semantic_logger"

Services = Canister.new
S = Services

S.register(:version) do
  ENV["APP_VERSION"] || "APP_VERSION"
end

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

S.register(:log_stream) do
  $stdout.sync = true
  $stdout
end

S.register(:logger) do
  SemanticLogger["catalog-browse"]
end

case ENV["APP_ENV"]
when "production"
  SemanticLogger.add_appender(io: S.log_stream, level: :info, formatter: :json)
when "test" # explicitly don't wnat an appender when running tests
  nil
else
  SemanticLogger.add_appender(io: S.log_stream, level: :info, formatter: :color)
end
