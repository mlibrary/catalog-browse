require "sinatra"
require "slim"

get "/" do

  # This should be the exact same list as Library Search Catalog Fields
  # Which should be able to pull from Spectrum? search.lib.umich.edu/spectrum
  # Albert can answer or know more. There is a chance this is in Solr too.
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

  # Same as above, this should probably come from Spectrum's response.
  # search.lib.umich.edu/spectrum
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
      # Set to false if not a match.
      # The FE will render unable to find a match if true or found if false.
      match: false
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
