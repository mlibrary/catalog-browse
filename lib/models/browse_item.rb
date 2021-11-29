class BrowseItem
  def initialize(catalog_doc, index_doc)
    @catalog_doc = catalog_doc || {}
    @index_doc = index_doc
  end
  def match_notice?
    false
  end
  #for the view
  def url
    "https://search.lib.umich.edu/catalog/record/#{mms_id}"
  end
  def title
    [bib_title, author].join(" ") 
  end
  def vernacular_title
    [vernacular_bib_title, vernacular_author].join(" ")
  end
  def callnumber
    @index_doc["callnumber"]&.strip
  end
  def subtitles
    [ author, publisher].compact
  end
  

  private
  #component pieces
  def mms_id
    @index_doc["bib_id"]
  end
  def bib_title
    @catalog_doc["title"]&.first
  end
  def vernacular_bib_title
    @catalog_doc["title"]&.slice(1)
  end
  def author
    @catalog_doc["mainauthor"]&.first
  end
  def vernacular_author
    @catalog_doc["mainauthor"]&.slice(1)
  end
  def publisher
    @catalog_doc["publisher"]&.first
  end
end
