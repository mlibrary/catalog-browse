class CallnumberList
  extend Forwardable
  def_delegators :@browse_list, :title, :help_text, :show_table?, :previous_url, :next_url, :match_text, :error?, :has_next_list?, :has_previous_list?, :next_reference_id, :previous_reference_id, :original_reference, :num_rows_to_display, :num_matches, :exact_matches, :banner_reference

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

  def initialize(browse_list:, catalog_response:)
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

  private

  def catalog_doc(bib_id)
    @catalog_docs.find { |x| x["id"] == bib_id }
  end
end
