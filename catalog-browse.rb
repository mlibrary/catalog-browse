require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/custom_logger"
require "byebug" if development?

require "yaml"
require "ostruct"

require_relative "lib/services"
require_relative "lib/catalog_solr_client"
require_relative "lib/utilities/browse_solr_client"
require_relative "lib/utilities/string_cleaner"
require_relative "lib/models/browse_list"
require_relative "lib/models/browse_list_presenter"
require_relative "lib/models/call_number_list"
require_relative "lib/models/call_number_item"
require_relative "lib/models/author_list"
require_relative "lib/models/author_item"
require_relative "lib/models/subject_list"
require_relative "lib/models/carousel_list"
require_relative "lib/models/subject_item"
require_relative "lib/models/search_dropdown"
require_relative "lib/models/datastores"

set :logger, S.logger
set :protection, except: [:json_csrf]

CatalogSolrClient.configure do |config|
  config.solr_url = S.biblio_solr
end

get "/subject" do
  subject = StringCleaner.clean_browse_string(params[:query])
  reference_id = params[:reference_id] || subject
  begin
    list = SubjectList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: subject, banner_reference: params[:banner_reference])
  rescue => e
    logger.error(e.message)
    list = SubjectList::Error.new(reference_id)
  end
  erb :subject, locals: {list: list}
end

get "/author" do
  author = StringCleaner.clean_browse_string(params[:query])
  reference_id = params[:reference_id] || author
  begin
    list = AuthorList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: author, banner_reference: params[:banner_reference])
  rescue => e
    logger.error(e.message)
    list = AuthorList::Error.new(reference_id)
  end
  erb :authors, locals: {list: list}
end
get "/callnumber" do
  call_number = params[:query]
  reference_id = params[:reference_id] || call_number
  begin
    list = CallNumberList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: call_number, banner_reference: params[:banner_reference])
  rescue => e
    logger.error(e.message)
    list = CallNumberList::Error.new(reference_id)
  end
  erb :call_number, locals: {list: list}
end

get "/carousel" do
  call_number = params[:query]
  begin
    content_type :json
    headers "Access-Control-Allow-Origin" => "*"
    CarouselList.list(call_number).to_json
  rescue => e
    logger.error(e.message)
    status 500
  end
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
