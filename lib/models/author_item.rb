class AuthorItem
  def self.for(browse_doc:, exact_match:)
    if browse_doc.key?("see_also")
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

  def author
    @browse_doc["term"]&.strip
  end

  def url
    params = {library: "U-M Ann Arbor Libraries", query: "author:(\"#{author}\")", "filter.search_only": false}
    "https://search.lib.umich.edu/catalog?#{URI.encode_www_form(params)}"
  end

  def results_count
    @browse_doc["count"]
  end

  def record_text
    "#{results_count} record#{"s" if results_count != 1}"
  end

  # mrio: commenting out because it isn't currently used in the UI
  # def alternate_forms
  # @browse_doc["alternate_forms"]
  # end

  def has_cross_references?
    false
  end

  def heading_link?
    !!heading_link
  end

  def heading_link
    @browse_doc["loc_id"]
  end
end

class AuthorItemWithCrossReferences < AuthorItem
  def has_cross_references?
    true
  end

  def cross_references
    # see_instead because this still needs to be changed in solr
    @browse_doc["see_also"].map { |author| AuthorItemSeeAlso.new(author) }
  end
end

class AuthorItemSeeAlso
  attr_reader :author, :count
  def initialize(author)
    @author, @count = author.split("||").map { |x| x.strip }
  end

  def author_display
    "#{@author} (in author list)"
  end

  def record_text
    "#{count} record#{"s" if count != '1'}"
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
