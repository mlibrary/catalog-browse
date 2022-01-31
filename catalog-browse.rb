require "sinatra"
require "byebug"
require "yaml"
require_relative "lib/utilities/solr_client"
require_relative "lib/models/fake_authors"
require_relative "lib/models/browse_list"
require_relative "lib/models/browse_item"
require_relative "lib/models/search_dropdown"
require_relative "lib/models/datastores"

get '/author' do
  list = FakeAuthorList.new
  erb :authors, :layout => false, :locals => { :list => list }
end
get '/callnumber' do
  fields = YAML.load_file("./config/search_dropdown.yml")
  datastores = Datastores.new(YAML.load_file("./config/datastores.yml"))
  
  callnumber = params[:query]
  reference_id = params[:reference_id] || callnumber 
  begin
    list = BrowseList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: callnumber, banner_reference: params[:banner_reference])
  rescue
    list = BrowseList::Error.new(reference_id)
  end
  erb :layout, :locals  => {
    :fields => fields,
    :datastores => datastores,
    :list => list 
  }
end
post "/search" do
  redirect SearchDropdown.for(type: params["type"], query: params["query"]).url
end
get "/" do
  # Landing page
end
