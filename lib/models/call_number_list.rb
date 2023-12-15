class CallNumberList < BrowseListPresenter
  def self.for(direction:, reference_id:, num_rows_to_display:, original_reference:, banner_reference:)
    browse_list = BrowseList.for(
      direction: direction,
      reference_id: reference_id,
      num_rows_to_display: num_rows_to_display,
      original_reference: original_reference,
      banner_reference: banner_reference
    )

    bib_ids = browse_list.docs.map { |x| x["bib_id"] }
    catalog_response = CatalogSolrClient.client.get_bibs(bib_ids: bib_ids).body
    new(browse_list: browse_list, catalog_response: catalog_response)
  end

  def initialize(browse_list:, catalog_response: nil)
    @browse_list = browse_list
    @catalog_docs = catalog_response&.dig("response", "docs")
  end

  def name
    "call number"
  end

  def path
    "callnumber"
  end

  def doc_title
    "Browse by Call Number (Library of Congress and Dewey)"
  end

  def items
    banner_index = nil
    match_notice = OpenStruct.new(callnumber: original_reference.upcase, match_notice?: true)
    my_items = @browse_list.docs.map.with_index do |browse_doc, index|
      exact_match = exact_matches.any?(browse_doc["id"])
      banner_match = (banner_reference == browse_doc["id"])
      banner_index = index if (exact_match || banner_match) && banner_index.nil?
      CallNumberItem.new(browse_doc: browse_doc, catalog_doc: catalog_doc(browse_doc["bib_id"]), exact_match: exact_match)
    end
    banner_index.nil? ? my_items : my_items.insert(banner_index, match_notice)
  end

  def help_text
    '<span class="strong">Browse by call number help:</span> Search a Library of Congress (LC) or Dewey call number and view an alphabetical list of all call numbers and related titles indexed in the Library catalog. <a href="https://guides.lib.umich.edu/c.php?g=282937">Learn more about call numbers<span class="visually-hidden"> (link points to external site)</span></a>.'
  end

  private

  def catalog_doc(bib_id)
    @catalog_docs.find { |x| x["id"] == bib_id }
  end
end

class CallNumberList::Error < CallNumberList
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
    "<span class=\"strong\">#{original_reference}</span> is not a valid call number query. Please try a using a valid Library of Congress call number (enter one or two letters and a number) or valid Dewey call number (start with three numbers)."
  end
end
