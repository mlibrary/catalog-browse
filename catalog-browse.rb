require "sinatra"
require "byebug"
require_relative "lib/utilities/solr_client"
require_relative "lib/models/browse_list"
require_relative "lib/models/browse_item"
require_relative "lib/models/search_dropdown"


get '/callnumber' do
  fields = 
  [
    { 
      label: "Search by",
      options: [
        {
          label: "Keyword",
          value: "keyword"
        },
        {
          label: "Title",
          value: "title"
        },
        {
          label: "Author",
          value: "author"
        },
        {
          label: "Journal/Serial Title",
          value: "journal_title"
        },
        {
          label: "Academic Discipline",
          value: "academic_discipline"
        },
        {
          label: "Call Number starts with",
          value: "call_number_starts_with"
        },
        {
          label: "Series (transcribed)",
          value: "series"
        },
        {
          label: "Year of Publication",
          value: "publication_date",
        },
        {
          label: "ISBN/ISSN/OCLC/etc",   
          value: "isn"
        },
      ]
    },
    {
      label: "Browse by",
      options: [
        {
          label: "Browse by LC call number",
          value: "browse_by_lc_callnumber",
          selected: "selected"
        },
        {
          label: "Browse by subject (coming soon)", 
          value: "browse_by_subject",
          disabled: "disabled"
        }
      ]
    }
  ]
  

  datastores = [
    {
      label: "Everything",
      href: "http://search.lib.umich.edu/everything"
    },
    {
      label: "Catalog",
      href: "http://search.lib.umich.edu/catalog",
      current: true
    },
    {
      label: "Articles",
      href: "http://search.lib.umich.edu/articles"
    },
    {
      label: "Databases",
      href: "http://search.lib.umich.edu/databases"
    },
    {
      label: "Online Journals",
      href: "http://search.lib.umich.edu/onlinejournals"
    },
    {
      label: "Guides and more",
      href: "http://search.lib.umich.edu/guidesandmore"
    }
  ]
    
    callnumber = params[:query]
    redirect "/" if callnumber.nil?
    reference_id = params[:reference_id] || callnumber 
    list = BrowseList.for(direction: params[:direction], reference_id: reference_id, num_rows_to_display: 20, original_reference: callnumber)
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
