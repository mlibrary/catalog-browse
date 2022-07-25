class AuthorList
  extend Forwardable
  def_delegators :@browse_list, :show_table?, :previous_url, :next_url, :match_text, :error?, :has_next_list?, :has_previous_list?, :next_reference_id, :previous_reference_id, :original_reference, :num_rows_to_display, :num_matches, :exact_matches, :banner_reference

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

  def items
    banner_index = nil
    match_notice = OpenStruct.new(author: original_reference.upcase, match_notice?: true)
    my_items = @browse_list.docs.map.with_index do |browse_doc, index|
      exact_match = exact_matches.any?(browse_doc["id"])
      banner_match = (banner_reference == browse_doc["id"])
      banner_index = index if (exact_match || banner_match) && banner_index.nil?
      AuthorItem.new(browse_doc: browse_doc, exact_match: exact_match)
    end
    banner_index.nil? ? my_items : my_items.insert(banner_index, match_notice)
  end

  def title
    if show_table?
      "Browse &ldquo;#{@original_reference}&rdquo; in authors"
    else
      "Browse by Author"
    end
  end
  def help_text
  end

end
