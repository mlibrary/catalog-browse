class AuthorItem
  def initialize(browse_doc:, exact_match:)
    @browse_doc = browse_doc
    @exact_match = exact_match
  end

  def match_notice?
    false
  end

  def exact_match?
    !!@exact_match
  end

  # for the view
  def author
    @browse_doc["author"]&.strip
  end

  def url
    "https://search.lib.umich.edu/catalog?library=U-M+Ann+Arbor+Libraries&query=author%3A(#{author})"
  end

  def results_count
    @browse_doc["count"]
  end

  def record_text
    "#{results_count} #{results_count == 1 ? "record" : "records"}"
  end

  def alternate_forms
    @browse_doc["alternate_forms"]
  end

  def has_cross_references?
    false
  end

  def heading_link?
    !!heading_link
  end

  def heading_link
    @browse_doc["heading_link"]
  end
end
