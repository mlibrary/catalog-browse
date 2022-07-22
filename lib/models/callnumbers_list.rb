class CallnumbersList 
  extend Forwardable
  def_delegators :@browse_list, :title, :help_text, :show_table?, :previous_url, :next_url, :items,:match_text, :error?, :has_next_list?, :has_previous_list?, :next_reference_id, :previous_reference_id, :original_reference, :num_rows_to_display, :num_matches

  def self.for( direction:, reference_id:, num_rows_to_display:, original_reference:, banner_reference: )
    browse_list = BrowseList.for(
      direction: direction, 
      reference_id: reference_id, 
      num_rows_to_display: num_rows_to_display, 
      original_reference: original_reference, 
      banner_reference: banner_reference)
    self.new(browse_list: browse_list)
  end
  
  def initialize(browse_list:)
    @browse_list = browse_list
  end
end
