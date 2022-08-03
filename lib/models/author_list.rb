class AuthorList < BrowseListPresenter
  def self.for(direction:, reference_id:, num_rows_to_display:, original_reference:, banner_reference:)
    browse_list = BrowseList.for(
      direction: direction,
      reference_id: reference_id,
      num_rows_to_display: num_rows_to_display,
      original_reference: original_reference,
      banner_reference: banner_reference,
      browse_solr_client: BrowseSolrClient.new(core: ENV.fetch("AUTHORS_CORE"), match_field: "author")
    )

    new(browse_list: browse_list)
  end

  def initialize(browse_list:)
    @browse_list = browse_list
  end

  def name
    "author"
  end

  def path
    "author"
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
    '<span class="strong">Browse by author help:</span> Search an author (last name, first name) and view an alphabetical list of all authors headings (personal names and corporate names) and variations of those names indexed in the Library catalog.'
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
