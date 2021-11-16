class BrowseItem
  def self.for(catalog_doc, index_doc)
    if catalog_doc
      self.new(catalog_doc, index_doc)
    else
      BrowseItem::NotFound.new(catalog_doc, index_doc)
    end
  end
  def initialize(catalog_doc, index_doc)
    @catalog_doc = catalog_doc || {}
    @index_doc = index_doc
  end
  #for the view
  def title
    [bib_title, author].join(" ") 
  end
  def url
    "https://search.lib.umich.edu/catalog/record/#{mms_id}"
  end
  def alternate_title
    [alternate_bib_title, alternate_author].join(" ")
  end
  def callnumber
    @index_doc["callnumber"].strip
  end
  def subtitles
    [ author, publisher].compact
  end
  

  #component pieces
  def mms_id
    @index_doc["bib_id"]
  end
  def bib_title
    @catalog_doc["title"]&.first
  end
  def alternate_bib_title
    @catalog_doc["title"]&.slice(1)
  end
  def author
    @catalog_doc["mainauthor"]&.first
  end
  def alternate_author
    @catalog_doc["mainauthor"]&.slice(1)
  end
  def publisher
    @catalog_doc["publisher"]&.first
  end
  def match?
    nil
  end
  def not_found?
    false
  end
end
class BrowseItem::NotFound < BrowseItem
  def not_found?
    true
  end
end
