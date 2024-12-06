class CarouselList
  def self.list(call_number, browse_solr_client = BrowseSolrClient.new, catalog_client = CatalogSolrClient.client)
    before = browse_solr_client.browse_reference_on_bottom(reference_id: call_number, rows: 22, field: "callnumber").body["response"]["docs"].reverse
    after = browse_solr_client.browse_reference_on_top(reference_id: call_number, rows: 23, field: "callnumber").body["response"]["docs"]

    ordered_call_number_docs = [before, after].flatten

    bib_ids = ordered_call_number_docs.map { |x| x["bib_id"] }
    catalog_response = catalog_client.get_bibs(bib_ids: bib_ids).body
    items = ordered_call_number_docs.map do |browse_doc|
      catalog_doc = catalog_response["response"]["docs"].find do |x|
        x["id"] == browse_doc["bib_id"]
      end || {}
      CarouselItem.new(catalog_doc, browse_doc)
    end
    items.map { |x| x.to_h }
  end

  class CarouselItem
    def initialize(catalog_doc, browse_doc)
      @catalog_doc = catalog_doc
      @browse_doc = browse_doc
    end

    def title
      @catalog_doc["title_display"]&.first
    end

    def author
      @catalog_doc["main_author_display"]&.first
    end

    def call_number
      @browse_doc["callnumber"]&.strip
    end

    def isbn
      @catalog_doc["isbn"]&.first&.strip
    end

    def issn
      @catalog_doc["issn"]&.first&.strip
    end

    def oclc
      @catalog_doc["oclc"]&.first&.strip
    end

    def mms_id
      @browse_doc["bib_id"]
    end

    def date
      @catalog_doc["display_date"]
    end

    def url
      "https://search.lib.umich.edu/catalog/record/#{mms_id}"
    end

    def to_h
      {
        title: title,
        author: author,
        date: date,
        call_number: call_number,
        isbn: isbn,
        issn: issn,
        oclc: oclc,
        url: url
      }
    end
  end
end
