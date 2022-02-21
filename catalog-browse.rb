require "sinatra"
require "sinatra/namespace"
require "byebug"
require "yaml"
require_relative "lib/utilities/solr_client"
require_relative "lib/models/fake_authors"
require_relative "lib/models/fake_subjects"
require_relative "lib/models/browse_list"
require_relative "lib/models/browse_item"
require_relative "lib/models/search_dropdown"
require_relative "lib/models/datastores"

if ENV.fetch("AUTHOR_ON") == "true"
  get "/author" do
    list = FakeAuthorList.new
    erb :'browse', :locals => { :option => 'author', :list => list, :list => list, :title => list.title }
  end
end

if ENV.fetch("SUBJECT_ON") == "true"
  namespace "/subject" do
    get "" do
      list = FakeSubjectList.new
      erb :'browse', :locals => { :option => 'subject', :list => list, :title => list.title }
    end
  end
end
get "/callnumber" do
  callnumber = params[:query]
  reference_id = params[:reference_id] || callnumber 
  begin
    list = BrowseList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: callnumber, banner_reference: params[:banner_reference])
  rescue
    list = BrowseList::Error.new(reference_id)
  end
  erb :'browse', :locals => { :option => 'callnumber', :list => list, :title => list.title }
end
post "/search" do
  redirect SearchDropdown.for(type: params["type"], query: params["query"]).url
end
get "/" do
  # Landing page
end
