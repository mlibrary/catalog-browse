class CallnumberList
  extend Forwardable
  def_delegators :@browse_list, :show_table?, :error?, :has_next_list?, :has_previous_list?, :next_reference_id, :previous_reference_id, :original_reference, :num_rows_to_display, :num_matches, :exact_matches, :banner_reference, :error_message

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

  def items
    banner_index = nil
    match_notice = OpenStruct.new(callnumber: original_reference.upcase, match_notice?: true)
    my_items = @browse_list.docs.map.with_index do |browse_doc, index|
      exact_match = exact_matches.any?(browse_doc["id"])
      banner_match = (banner_reference == browse_doc["id"])
      banner_index = index if (exact_match || banner_match) && banner_index.nil?
      CallnumberItem.new(browse_doc: browse_doc, catalog_doc: catalog_doc(browse_doc["bib_id"]), exact_match: exact_match)
    end
    banner_index.nil? ? my_items : my_items.insert(banner_index, match_notice)
  end

  def title
    if show_table?
      "Browse &ldquo;#{original_reference}&rdquo; in call numbers"
    else
      "Browse by Call Number"
    end
  end

  def help_text
    '<span class="strong">Browse by call number help:</span> Search a Library of Congress (LC) or Dewey call number and view an alphabetical list of all call numbers and related titles indexed in the Library catalog. <a href="https://guides.lib.umich.edu/c.php?g=282937">Learn more about call numbers<span class="visually-hidden"> (link points to external site)</span></a>.'
  end

  def previous_url
    nav_url(@browse_list.previous_url_params)
  end

  def next_url
    nav_url(@browse_list.next_url_params)
  end

  def match_text
    case num_matches
    when 0
      "<span class=\"strong\">#{original_reference}</span> would appear here. There's no exact match for that call number in our catalog."
    when 1
      "We found a matching call number in our catalog for: <span class=\"strong\">#{original_reference}</span>."
    else
      "We found #{num_matches} matching items in our catalog for the call number: <span class=\"strong\">#{original_reference}</span>"
    end
  end

  private

  def nav_url(params)
    "#{ENV.fetch("BASE_URL")}/callnumber?#{URI.encode_www_form(params)}"
  end

  def catalog_doc(bib_id)
    @catalog_docs.find { |x| x["id"] == bib_id }
  end
end

class CallnumberList::Error < CallnumberList
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
