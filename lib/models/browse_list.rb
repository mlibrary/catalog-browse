require 'simple_solr_client'
class BrowseList
  def self.for(direction:,reference_id:,num_rows_to_display:,
               solr_client: SimpleSolrClient::Client.new( ENV.fetch('CATALOG_SOLR') )

  end
  def initialize(index_response:, biblio_response:, num_rows_to_display:)
    @index_docs = index_response&.dig("response","docs")
    @catalog_docs = biblio_response&.dig("response","docs")
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
  def items
    @index_docs[*item_range].map do |index_doc|
      BrowseItem.for(catalog_doc_for_mms_id(index_doc["bib_id"]), index_doc)
    end
  end
  private
  def catalog_doc_for_mms_id(mms_id)
    @catalog_docs.find{|x| x["id"] == mms_id}
  end
  def item_range
    if has_previous_list?
      [1,@num_rows_to_display] 
    elsif has_next_list? && !has_previous_list?
      [0, @index_docs.count - 1]
    else
      [0, @index_docs.count]
    end
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

class BrowseItem
  def self.for(catalog_doc, index_doc)
    if catalog_doc
      self.new(catalog_doc, index_doc)
    else
    end
  end
  def initialize(catalog_doc, index_doc)
    @catalog_doc = catalog_doc
    @index_doc = index_doc
  end
  def callnumber
    @index_doc["callnumber"].strip
  end
  def mms_id
    @index_doc["bib_id"]
  end
  def title
    @doc["title"]&.first
  end
end
