require "faraday"

class BrowseSolrClient
  def initialize(solr_url: ENV.fetch("CATALOG_SOLR"), core: ENV.fetch("CALLNUMBERS_CORE") ) 
      @conn = Faraday.new(
        url: solr_url 
      ) do |f|
        f.request :json
        #  f.request :retry, {max: 1, retry_statuses: [500]}
        f.response :json
      end
      @path_prefix = "/solr/#{core}" 
  end
  
  def browse_reference_on_top(reference_id:, rows: 20)
    # square brackets includes reference in return
    range = "id:[\"#{reference_id}\" TO *]"
    sort = "id asc"
    browse(rows: rows, sort: sort, range: range)
  end

  def browse_reference_on_bottom(reference_id:, rows: 20)
    # curly brackets exclues reference in return
    range = "id:{* TO \"#{reference_id}\"}"
    sort = "id desc"
    browse(rows: rows, sort: sort, range: range)
  end

  def browse(rows:, sort:, range:)
    query = {
      rows: rows,
      q: "*:*",
      fq: [range],
      sort: sort
    }
    @conn.public_send(:get, "#{@path_prefix}/select", query)
  end

  #just for callnumbers?
  def exact_matches(callnumber:)
    query = {
      q: "*:*",
      fq: %(callnumber:"#{callnumber}"),
      sort: "id asc",
      rows: 5000
    }
    result = @conn.public_send(:get, "#{@path_prefix}/select", query)
    if result.status != 200
      []
    else
      result.body["response"]["docs"]&.map { |x| x["id"] }
    end
  end
end
