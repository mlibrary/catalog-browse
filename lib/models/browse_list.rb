class BrowseList
  def initialize(index_response:, biblio_response:, num_rows_to_display:)
    @index_docs = index_response&.dig("response","docs")
    @biblio_docs = biblio_response&.dig("response","docs")
    @num_rows_to_display = num_rows_to_display
  end
  def next_reference_id
    @index_docs[@index_docs.count - 2][reference_field].strip if has_next_list?
  end
  def previous_reference_id
    @index_docs[1][reference_field].strip if has_previous_list?
  end
  def reference_field
    'callnumber'
  end
end

class BrowseList::ReferenceAtTop < BrowseList
  def has_next_list?
    @index_docs.count == @num_rows_to_display + 2
  end
  def has_previous_list?
    true
  end
end
