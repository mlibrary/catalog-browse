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
  def callnumber
    @index_doc["callnumber"].strip
  end
  def mms_id
    @index_doc["bib_id"]
  end
  def title
    @catalog_doc["title"]&.first
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
