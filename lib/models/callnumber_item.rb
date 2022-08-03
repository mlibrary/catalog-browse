class CallnumberItem
  def initialize(browse_doc:, catalog_doc:, exact_match:)
    @browse_doc = browse_doc
    @catalog_doc = catalog_doc
    @exact_match = exact_match
  end

  def match_notice?
    false
  end

  def exact_match?
    !!@exact_match
  end

  # for the view
  def callnumber
    @browse_doc["callnumber"]&.strip
  end

  def url
    "https://search.lib.umich.edu/catalog/record/#{mms_id}"
  end

  def title
    [@catalog_doc["title_display"]&.first, edition].compact.join(" ")
  end

  def vernacular_title
    output = @catalog_doc["title_display"]&.slice(1)
    [output, vernacular_edition].compact.join(" ") unless output.nil?
  end

  def author
    @catalog_doc["main_author_display"]&.first
  end

  def vernacular_author
    @catalog_doc["main_author_display"]&.slice(1)
  end

  def publisher
    @catalog_doc["publisher_display"]&.first
  end

  def vernacular_publisher
    @catalog_doc["publisher_display"]&.slice(1)
  end

  def series
    @catalog_doc["series_statement"]&.first
  end

  def vernacular_series
    @catalog_doc["series_statement"]&.slice(1)
  end

  private

  # component pieces
  def edition
    @catalog_doc["edition"]&.first
  end

  def vernacular_edition
    @catalog_doc["edition"]&.slice(1)
  end

  def mms_id
    @browse_doc["bib_id"]
  end
end
