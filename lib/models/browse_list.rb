class BrowseList
  attr_reader :original_reference, :num_rows_to_display
  def self.for(direction:,reference_id:,num_rows_to_display:, original_reference:,
               solr_client: SolrClient.new)
    case direction
    when 'next'
      #includes reference in results
      index_response = solr_client.browse_reference_on_top(reference_id: reference_id, rows: num_rows_to_display + 2)
    when 'previous'
      #doesn't include reference in results
      index_response = solr_client.browse_reference_on_bottom(reference_id: reference_id, rows: num_rows_to_display + 1)
    else
  #index_before:, index_after:, index_exact:, 
      index_before = solr_client.browse_reference_on_bottom(reference_id: reference_id, rows: 3)
      index_after = solr_client.browse_reference_on_top(reference_id: reference_id, rows: num_rows_to_display - 1)
      index_exact = solr_client.browse_reference_on_top(reference_id: reference_id, rows: 1)
      #need above and below
    end
  
    #if index_response.code != 200
      ##Do some error handling
    #end
    if index_response 
      bib_ids = index_response.parsed_response.dig("response","docs").map{|x| x["bib_id"] }
    else
      bib_ids = [index_before.parsed_response.dig("response","docs"), index_after.parsed_response.dig("response","docs")].flatten.map{|x| x["bib_id"]}
    end
    catalog_response = solr_client.get_bibs(bib_ids: bib_ids)
    #if catalog_response.code != 200
      ##Do some error handling
    #end
 
    case direction
    when "next" 
      BrowseList::ReferenceOnTop.new(index_response: index_response.parsed_response, catalog_response: catalog_response.parsed_response, num_rows_to_display: num_rows_to_display, original_reference: original_reference) 
    when "previous"
      BrowseList::ReferenceOnBottom.new(index_response: index_response.parsed_response, catalog_response: catalog_response.parsed_response, num_rows_to_display: num_rows_to_display, original_reference: original_reference ) 
    else
      BrowseList::ReferenceInMiddle.new(
        index_before: index_before.parsed_response, 
        index_after: index_after.parsed_response, 
        index_exact: index_exact.parsed_response, 
        catalog_response: catalog_response.parsed_response, 
        num_rows_to_display: num_rows_to_display,
        original_reference: original_reference) 
    end

  end
  def initialize(index_response:, catalog_response:, num_rows_to_display:, original_reference:)
    @original_reference = original_reference
    @catalog_docs = catalog_response&.dig("response","docs")
    @num_rows_to_display = num_rows_to_display
    @index_docs = index_response&.dig("response","docs")
  end
  def reference_field
    'callnumber'
  end
  def previous_url
    #"/callnumber/#{@original_reference}?direction=previous&reference_id=#{previous_reference_id}&num_rows_to_display=#{@num_rows_to_display}"
    "/callnumber/#{@original_reference}?direction=previous&reference_id=#{previous_reference_id}"
  end
  def next_url
    #"/callnumber/#{@original_reference}?direction=next&reference_id=#{next_reference_id}&num_rows_to_display=#{@num_rows_to_display}"
    "/callnumber/#{@original_reference}?direction=next&reference_id=#{next_reference_id}"
  end
  def items
    @index_docs[*item_range].map do |index_doc|
      BrowseItem.for(catalog_doc_for_mms_id(index_doc["bib_id"]), index_doc)
    end
  end
  private
  def catalog_doc_for_mms_id(mms_id)
    @catalog_docs.find{|x| x["id"] == mms_id}
  end
end

class BrowseList::ReferenceOnTop < BrowseList
  def has_next_list?
    @index_docs.count == @num_rows_to_display + 2
  end
  def has_previous_list?
    true
  end
  def item_range
      [1,@num_rows_to_display] 
  end
  def next_reference_id
    @index_docs[@index_docs.count - 2]["id"].strip if has_next_list?
  end
  def previous_reference_id
    @index_docs[1]["id"].strip if has_previous_list?
  end
end

class BrowseList::ReferenceOnBottom < BrowseList
  def initialize(index_response:, catalog_response:, num_rows_to_display:, original_reference:)
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
    @index_docs[@index_docs.count - 1]["id"].strip if has_next_list?
  end
  def previous_reference_id
    @index_docs[0]["id"].strip if has_previous_list?
  end
  def item_range
    [1, @num_rows_to_display]
  end
end

class BrowseList::ReferenceInMiddle < BrowseList::ReferenceOnTop
  def initialize(index_before:, index_after:, index_exact:, 
                 catalog_response:, num_rows_to_display:, original_reference:)
    @original_reference = original_reference
    @catalog_docs = catalog_response&.dig("response","docs")
    @num_rows_to_display = num_rows_to_display
    @index_docs = get_index_docs(index_before, index_exact, index_after, original_reference)
  end
  private
  def get_index_docs(index_before, index_exact, index_after, original_reference)
    before_docs = index_before.dig("response","docs").reverse
    exact_doc = index_exact.dig("response","docs")
    after_docs = index_after.dig("response","docs")
  
    if exact_doc.count == 0
      [before_docs, {callnumber: original_reference}, after_docs[0, after_docs.count-1]].flatten
    else
      [before_docs, after_docs].flatten
    end 
  end
end

