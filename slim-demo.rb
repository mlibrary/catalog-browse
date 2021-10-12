require "sinatra"
require "slim"

get "/" do
  fields = [
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
    },
    {
      label: "Browse by (LC) call number",
      value: "browse-by-callnumber"
    }
  ]

  slim :browse, :locals => { :fields => fields}
end
