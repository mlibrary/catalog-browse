class BrowseList
  attr_reader :original_reference, :num_rows_to_display, :num_matches
  def self.for(direction:,reference_id:,num_rows_to_display:, original_reference:,
               banner_reference:,
               solr_client: SolrClient.new)

    my_banner_reference = banner_reference 
    exact_matches = solr_client.exact_matches(callnumber: original_reference)
    case direction
    when 'next'
      #includes reference in results
      index_response = solr_client.browse_reference_on_top(reference_id: reference_id, rows: num_rows_to_display + 2)
    when 'previous'
      #doesn't include reference in results
      index_response = solr_client.browse_reference_on_bottom(reference_id: reference_id, rows: num_rows_to_display + 1)
    else
    #index_before:, index_after:
      index_before = solr_client.browse_reference_on_bottom(reference_id: reference_id, rows: 3)
      index_after = solr_client.browse_reference_on_top(reference_id: reference_id, rows: num_rows_to_display - 1)
      my_banner_reference = index_after.parsed_response.dig("response","docs").first["id"]
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
      BrowseList::ReferenceOnTop.new(
        index_response: index_response.parsed_response, 
        catalog_response: catalog_response.parsed_response, 
        num_rows_to_display: num_rows_to_display, 
        original_reference: original_reference,
        exact_matches: exact_matches,
        banner_reference: my_banner_reference
      ) 
    when "previous"
      BrowseList::ReferenceOnBottom.new(
        index_response: index_response.parsed_response, 
        catalog_response: catalog_response.parsed_response, 
        num_rows_to_display: num_rows_to_display, 
        original_reference: original_reference,
        exact_matches: exact_matches,
        banner_reference: my_banner_reference
      ) 
    else
      BrowseList::ReferenceInMiddle.new(
        index_before: index_before.parsed_response, 
        index_after: index_after.parsed_response, 
        catalog_response: catalog_response.parsed_response, 
        num_rows_to_display: num_rows_to_display,
        original_reference: original_reference,
        exact_matches: exact_matches,
        banner_reference: my_banner_reference
      ) 
    end

  end
  def initialize(index_response:, catalog_response:, num_rows_to_display:, original_reference:, exact_matches:, banner_reference:)
    @original_reference = original_reference
    @catalog_docs = catalog_response&.dig("response","docs")
    @num_rows_to_display = num_rows_to_display
    @index_docs = index_response&.dig("response","docs")
    @num_matches = exact_matches.count
    @exact_matches = exact_matches
    @banner_reference = banner_reference
  end
  def previous_url
    params = URI.encode_www_form({
      query: @original_reference, 
      direction: "previous",
      reference_id: previous_reference_id,
      banner_reference: @banner_reference
    })
    "#{ENV.fetch("BASE_URL")}/callnumber?#{params}"
  end
  def next_url
    params = URI.encode_www_form({
      query: @original_reference, 
      direction: "next",
      reference_id: next_reference_id,
      banner_reference: @banner_reference
    })
    "#{ENV.fetch("BASE_URL")}/callnumber?#{params}"
  end
  def items
    banner_index = nil
    match_notice = OpenStruct.new(callnumber: @original_reference.upcase, match_notice?: true)
    my_items = @index_docs[1, @num_rows_to_display].map.with_index do |index_doc, index|
      exact_match = exact_match_for?(index_doc["id"])
      banner_match = (@banner_reference == index_doc["id"])
      banner_index = index if (exact_match || banner_match) && banner_index.nil?
      BrowseItem.new(catalog_doc_for_mms_id(index_doc["bib_id"]), index_doc, exact_match)
    end
    banner_index.nil? ? my_items : my_items.insert(banner_index, match_notice) 
  end

  def match_text
    case @num_matches
    when 0
      "<span class=\"strong\">#{@original_reference}</span> would appear here. There's no exact match for that call number in our catalog."
    when 1
      "We found a matching call number in our catalog for: <span class=\"strong\">#{original_reference}</span>."
    else
      "We found #{@num_matches} matching items in our catalog for the call number: <span class=\"strong\">#{original_reference}</span>"
    end
  end

  private
  def catalog_doc_for_mms_id(mms_id)
    @catalog_docs.find{|x| x["id"] == mms_id}
  end
  def exact_match_for?(id)
    @exact_matches.any?(id)
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
  def initialize(index_response:, catalog_response:, num_rows_to_display:, original_reference:, exact_matches:, banner_reference:)
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
                 catalog_response:, num_rows_to_display:, 
                 original_reference:, exact_matches:, banner_reference:
                )
    @exact_matches = exact_matches
    @num_matches = exact_matches.count
    @original_reference = original_reference
    @catalog_docs = catalog_response&.dig("response","docs")
    @num_rows_to_display = num_rows_to_display
    @banner_reference = banner_reference
    @index_docs = get_index_docs(index_before, index_after)
  end
  private
  def get_index_docs(index_before, index_after)
    before_docs = index_before.dig("response","docs").reverse
    after_docs = index_after.dig("response","docs")
    [before_docs, after_docs].flatten
  end
end

