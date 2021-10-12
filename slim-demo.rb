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

  results = [
    {
      callnumber: 'Z 253 .U582 1984',
      title: 'Patents and trademarks style menu :',
      subtitles: [
        'United States. Patent and Trademark Office.',
        'Office : For sale by the Supt. of Docs., U.S. G.P.O., 1984.'
      ]
    },
    {
      callnumber: 'Z 253 .U582 1984',
      title: 'Patents and trademarks style menu :',
      subtitles: [
        'United States. Patent and Trademark Office.',
        'Office : For sale by the Supt. of Docs., U.S. G.P.O., 1984.'
      ]
    },
    {
      callnumber: 'Z 253 .U582 1984',
      title: 'Patents and trademarks style menu :',
      subtitles: [
        'United States. Patent and Trademark Office.',
        'Office : For sale by the Supt. of Docs., U.S. G.P.O., 1984.'
      ]
    }
  ]

  slim :browse, :locals => { :fields => fields, :results => results}
end
