class BrowseList
  attr_reader :original_reference, :num_rows_to_display, :num_matches, :exact_matches, :banner_reference

  def self.for(direction:, reference_id:, num_rows_to_display:, original_reference:,
    banner_reference:,
    browse_solr_client: BrowseSolrClient.new)

    my_banner_reference = banner_reference
    exact_matches = browse_solr_client.exact_matches(value: original_reference)
    case direction
    when "next"
      # includes reference in results
      index_response = browse_solr_client.browse_reference_on_top(reference_id: reference_id, rows: num_rows_to_display + 2)
      BrowseList::ReferenceOnTop.new(
        index_response: index_response.body,
        num_rows_to_display: num_rows_to_display,
        original_reference: original_reference,
        exact_matches: exact_matches,
        banner_reference: my_banner_reference
      )
    when "previous"
      # doesn't include reference in results
      index_response = browse_solr_client.browse_reference_on_bottom(reference_id: reference_id, rows: num_rows_to_display + 1)
      BrowseList::ReferenceOnBottom.new(
        index_response: index_response.body,
        num_rows_to_display: num_rows_to_display,
        original_reference: original_reference,
        exact_matches: exact_matches,
        banner_reference: my_banner_reference
      )
    else
      # index_before:, index_after:
      return BrowseList::Empty.new if reference_id.nil?
      index_before = browse_solr_client.browse_reference_on_bottom(reference_id: reference_id, rows: 3)
      index_after = browse_solr_client.browse_reference_on_top(reference_id: reference_id, rows: num_rows_to_display - 1)
      my_banner_reference = index_after.body.dig("response", "docs").first["id"]
      # need above and below
      BrowseList::ReferenceInMiddle.new(
        index_before: index_before.body,
        index_after: index_after.body,
        num_rows_to_display: num_rows_to_display,
        original_reference: original_reference,
        exact_matches: exact_matches,
        banner_reference: my_banner_reference
      )
    end
  end

  def initialize(index_response:, num_rows_to_display:, original_reference:, exact_matches:, banner_reference:)
    @original_reference = original_reference
    @num_rows_to_display = num_rows_to_display
    @index_docs = index_response&.dig("response", "docs")
    @num_matches = exact_matches.count
    @exact_matches = exact_matches
    @banner_reference = banner_reference
  end

  def show_table?
    true
  end

  def previous_url_params
    {
      query: @original_reference,
      direction: "previous",
      reference_id: previous_reference_id,
      banner_reference: @banner_reference
    }
  end

  def next_url_params
    {
      query: @original_reference,
      direction: "next",
      reference_id: next_reference_id,
      banner_reference: @banner_reference
    }
  end

  def docs
    @index_docs[1, @num_rows_to_display]
  end

  def error?
    false
  end
end

class BrowseList::ReferenceOnTop < BrowseList
  def has_next_list?
    @index_docs.count == @num_rows_to_display + 2
  end

  def has_previous_list?
    true
  end

  def next_reference_id
    @index_docs[@index_docs.count - 2]["id"].strip if has_next_list?
  end

  def previous_reference_id
    @index_docs[1]["id"].strip if has_previous_list?
  end
end

class BrowseList::ReferenceOnBottom < BrowseList
  def initialize(index_response:, num_rows_to_display:, original_reference:, exact_matches:, banner_reference:)
    super
    @index_docs.reverse!
  end

  def has_next_list?
    true
  end

  def has_previous_list?
    @index_docs.count == @num_rows_to_display + 1
  end

  def next_reference_id
    @index_docs.last["id"].strip if has_next_list?
  end

  def previous_reference_id
    @index_docs[1]["id"].strip if has_previous_list?
  end
end

class BrowseList::ReferenceInMiddle < BrowseList::ReferenceOnTop
  def initialize(index_before:, index_after:,
    num_rows_to_display:,
    original_reference:, exact_matches:, banner_reference:)
    @exact_matches = exact_matches
    @num_matches = exact_matches.count
    @original_reference = original_reference
    @num_rows_to_display = num_rows_to_display
    @banner_reference = banner_reference
    @index_docs = get_index_docs(index_before, index_after)
  end

  private

  def get_index_docs(index_before, index_after)
    before_docs = index_before.dig("response", "docs").reverse
    after_docs = index_after.dig("response", "docs")
    [before_docs, after_docs].flatten
  end
end

class BrowseList::Empty < BrowseList
  def initialize(original_reference = "")
    @original_reference = original_reference
  end

  def show_table?
    false
  end
end
