class AuthorList < BrowseListPresenter
  def self.for(direction:, reference_id:, num_rows_to_display:, original_reference:, banner_reference:)
    browse_list = BrowseList.for(
      direction: direction,
      reference_id: reference_id,
      num_rows_to_display: num_rows_to_display,
      original_reference: original_reference,
      banner_reference: banner_reference,
      browse_solr_client: BrowseSolrClient.new(solr_url: S.author_solr, core: S.authority_core, match_field: "term", q: "browse_field:name", solr_cloud_on: S.solr_cloud_on?)
    )

    new(browse_list: browse_list)
  end

  def initialize(browse_list:)
    @browse_list = browse_list
  end

  def feedback_url
    # Author Browse specific url
    "https://umich.qualtrics.com/jfe/form/SV_43jm8oGIRVLEBbo"
  end

  def name
    "author"
  end

  def path
    "author"
  end

  def doc_title
    "Browse by Author"
  end

  def items
    banner_index = nil
    match_notice = OpenStruct.new(author: original_reference.upcase, match_notice?: true)
    my_items = @browse_list.docs.map.with_index do |browse_doc, index|
      exact_match = exact_matches.any?(browse_doc["id"])
      banner_match = (banner_reference == browse_doc["id"])
      banner_index = index if (exact_match || banner_match) && banner_index.nil?
      AuthorItem.for(browse_doc: browse_doc, exact_match: exact_match)
    end
    banner_index.nil? ? my_items : my_items.insert(banner_index, match_notice)
  end

  def help_text
    '<span class="strong">Browse by author help:</span> Search an author (last names, first name), organization or conference and view an alphabetical list of all author headings that link to matching records in the library catalog. Also view variations of some author names (pseudonyms) linked to that part of the author index.'
  end
end

class AuthorList::Error < AuthorList
  attr_reader :original_reference
  def initialize(original_reference = "")
    @original_reference = original_reference
  end

  def show_table?
    false
  end

  def error?
    true
  end

  def error_message
    "<span class=\"strong\">#{original_reference}</span> is not a valid author query."
  end
end
