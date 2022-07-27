class AuthorItem
  def self.for(browse_doc:, exact_match:)
    if browse_doc["record_type"] == "redirect"
      AuthorItemWithCrossReferences.new(browse_doc: browse_doc, exact_match: exact_match)
    else
      AuthorItem.new(browse_doc: browse_doc, exact_match: exact_match)
    end
  end
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
    params = {library: "U-M Ann Arbor Libraries", query: "author:(\"#{author}\")"}
    "https://search.lib.umich.edu/catalog?#{URI.encode_www_form(params)}"
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
    @browse_doc["naf_id"]
  end
end
class AuthorItemWithCrossReferences < AuthorItem
  def has_cross_references?
    true
  end
  def cross_references
    #see_instead because this still needs to be changed in solr
    @browse_doc["see_instead"].map{|author| AuthorItemSee.new(author) }
  end
end
class AuthorItemSee
  attr_reader :author
  def initialize(author)
    @author = author&.strip
  end
  def kind
    "see_also"
  end
  def url
    "#{ENV.fetch("BASE_URL")}/author?query=#{URI.encode_www_form_component(@author)}"
  end
  def heading_link?
    false
  end
  
end
