require "sinatra"
require "sinatra/reloader" if development?
require "byebug" if development?

require "yaml"

require_relative "lib/catalog_solr_client"
require_relative "lib/utilities/browse_solr_client"
require_relative "lib/models/browse_list"
require_relative "lib/models/browse_list_presenter"
require_relative "lib/models/callnumber_list"
require_relative "lib/models/callnumber_item"
require_relative "lib/models/author_list"
require_relative "lib/models/author_item"
require_relative "lib/models/search_dropdown"
require_relative "lib/models/datastores"

CatalogSolrClient.configure do |config|
  config.solr_url = ENV.fetch("BIBLIO_SOLR")
end

# Remove extraneous (and potentially damaging) stuff from the author string
# TODO: add bits to remove field prefix (e.g., 'author:') as defined in 00-catalog.yml
def cleanup_author_browse_string(str)
  str.gsub(/\p{P}\p{Sm}\p{Sc}\p{So}/, "")
end

if ENV.fetch("AUTHOR_ON") == "true"
  get "/author" do
    author = params[:query]
    query_string = cleanup_author_browse_string(author)
    reference_id = params[:reference_id] || query_string
    begin
      list = AuthorList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: author, banner_reference: params[:banner_reference])
    rescue => e
      logger.error(e.message)
      list = AuthorList::Error.new(reference_id)
    end
    erb :authors, locals: {list: list}
  end
end
get "/callnumber" do
  callnumber = params[:query]
  reference_id = params[:reference_id] || callnumber
  begin
    list = CallnumberList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: callnumber, banner_reference: params[:banner_reference])
  rescue => e
    logger.error(e.message)
    list = CallnumberList::Error.new(reference_id)
  end
  erb :call_number, locals: {list: list}
end
post "/search" do
  redirect SearchDropdown.for(type: params["type"], query: params["query"]).url
end

get "/" do
  # Landing page
end

get "/-/live" do
  200
end
