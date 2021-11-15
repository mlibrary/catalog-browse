require "sinatra"
require "slim"

get "/" do
  fields = [
    {
      label: "Browse by (LC) call number",
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
      ]
    },
    {
      match: true
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
    },
    {
      callnumber: 'Z 253 .U582 1984',
      title: 'Patents and trademarks style menu :',
      subtitles: [
        'United States. Patent and Trademark Office.',
        'Office : For sale by the Supt. of Docs., U.S. G.P.O., 1984.'
      ]
    },
  ]

  slim :browse, :locals => {
    :fields => fields,
    :datastores => datastores,
    :results => results,
  }
end
