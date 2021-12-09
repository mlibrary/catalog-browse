class BrowseItem
  def initialize(catalog_doc, index_doc, exact_match)
    @catalog_doc = catalog_doc || {}
    @index_doc = index_doc
    @exact_match = exact_match
  end
  def match_notice?
    false
  end
  def exact_match?
    !!@exact_match
  end
  #for the view
  def url
    "https://search.lib.umich.edu/catalog/record/#{mms_id}"
  end
  def title
    [@catalog_doc["title_display"]&.first, edition].compact.join(" ")
  end
  def vernacular_title
    output = @catalog_doc["title_display"]&.slice(1)
    [output, edition].compact.join(" ") unless output.nil?
  end
  def author
    @catalog_doc["mainauthor"]&.first
  end
  def vernacular_author
    @catalog_doc["mainauthor"]&.slice(1)
  end
  def callnumber
    @index_doc["callnumber"]&.strip
  end
  def subtitles
    [ author, publisher].compact
  end
  def publisher
    @catalog_doc["publisher"]&.first
  end
  def vernacular_publisher
    @catalog_doc["publisher"]&.slice(1)
  end
  

  private
  #component pieces
  def edition
    @catalog_doc["edition"]&.first
  end
  def mms_id
    @index_doc["bib_id"]
  end
  def bib_title
    @catalog_doc["title_display"]&.first
  end
  def bib_edition
    @catalog_doc["edition"]
  end
  def vernacular_bib_title
    @catalog_doc["title_display"]&.slice(1)
  end
  #publish brief?
end
