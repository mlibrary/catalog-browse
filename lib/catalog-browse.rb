require 'sinatra/base'

require "slim"
require "byebug"
require_relative "utilities/solr_client"
require_relative "models/browse_list"
require_relative "models/browse_item"
require_relative "catalog-browse/browse_css"

class CatalogBrowse < Sinatra::Base

  configure :production, :development do
    set :root, File.expand_path('../../', __FILE__)
    enable :logging
  end

  get '/callnumber' do
    fields = [
      {
        label: "Browse by LC call number",
        value: "browse-by-callnumber"
      },
      {
        label: "Keyword",
        value: "keyword"
      },
      {
        label: "Author",
        value: "author"
      },
      {
        label: "Title",
        value: "title"
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
    slim :browse, :locals  => {
      :fields => fields,
      :datastores => datastores,
      :list => list
    }
  end

  get "/" do
    # Landing page
  end

end
