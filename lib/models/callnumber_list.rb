class CallnumberList 
  extend Forwardable
  def_delegators :@browse_list, :title, :help_text, :show_table?, :previous_url, :next_url, :match_text, :error?, :has_next_list?, :has_previous_list?, :next_reference_id, :previous_reference_id, :original_reference, :num_rows_to_display, :num_matches

  def self.for( direction:, reference_id:, num_rows_to_display:, original_reference:, banner_reference: )
    browse_list = BrowseList.for(
      direction: direction, 
      reference_id: reference_id, 
      num_rows_to_display: num_rows_to_display, 
      original_reference: original_reference, 
      banner_reference: banner_reference)

    bib_ids = browse_list.items.map{|x| x["bib_id"] }
    catalog_response = CatalogSolrClient.client.get_bibs(bib_ids: bib_ids)
    self.new(browse_list: browse_list, catalog_response: catalog_response )
  end
  
  def initialize(browse_list:, catalog_response:)
    @browse_list = browse_list
    @catalog_response = catalog_response
  end
  def items
    @browse_list.items
  end
end
