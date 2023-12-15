class SubjectList < BrowseListPresenter
  def self.for(direction:, reference_id:, num_rows_to_display:, original_reference:, banner_reference:)
    browse_list = BrowseList.for(
      direction: direction,
      reference_id: reference_id,
      num_rows_to_display: num_rows_to_display,
      original_reference: original_reference,
      banner_reference: banner_reference,
      browse_solr_client: BrowseSolrClient.new(core: S.authority_collection, match_field: "term", q: "browse_field:subject")
    )

    new(browse_list: browse_list)
  end

  def initialize(browse_list:)
    @browse_list = browse_list
  end

  def feedback_url
    # Subject Browse specific url
    "https://umich.qualtrics.com/jfe/form/SV_brwYt0B1fSx0zFI"
  end

  def name
    "subject"
  end

  def path
    "subject"
  end

  def doc_title
    "Browse by Subject"
  end

  def items
    banner_index = nil
    match_notice = OpenStruct.new(subject: original_reference.upcase, match_notice?: true)
    my_items = @browse_list.docs.map.with_index do |browse_doc, index|
      exact_match = exact_matches.any?(browse_doc["id"])
      banner_match = (banner_reference == browse_doc["id"])
      banner_index = index if (exact_match || banner_match) && banner_index.nil?
      SubjectItem.for(browse_doc: browse_doc, exact_match: exact_match)
    end
    banner_index.nil? ? my_items : my_items.insert(banner_index, match_notice)
  end

  def help_text
    '<span class="strong">Browse by subject help:</span> Search within an alphabetical list of all <a href="https://id.loc.gov/authorities/subjects.html" target="_blank" rel="noopener noreferrer">Library of Congress Subject Headings<span class="visually-hidden"> - Opens in new window</span><span class="material-symbols-sharp">open_in_new</span></a> (LCSH) indexed in the Library catalog.'
  end
end

class SubjectList::Error < SubjectList
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
    "<span class=\"strong\">#{original_reference}</span> is not a valid subject query."
  end
end
